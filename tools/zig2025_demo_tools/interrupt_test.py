import argparse
import logging
import unittest
import sys

from pw_log.log_decoder import (
    timestamp_parser_ms_since_boot,
)
from pw_system.device import (
    Device,
)
from pw_system.device_connection import (
    add_device_args,
    create_device_serial_or_socket_connection,
    DeviceConnection,
)
from pw_system.device_tracing import (
    DeviceWithTracing,
)
from proto import zig2025_pb2

device = None

_LOG = logging.getLogger("unittest")

class InterruptTest(unittest.TestCase):

    def test_interrupts(self):
        self.assertIsNotNone(device)
        service = device.rpcs.com.google.zig2025.ZigService

        for i in range(5):
            result = service.TriggerInterrupt()
            self.assertTrue(result.status.ok())

        result = service.GetInterruptCount()
        self.assertTrue(result.status.ok())
        self.assertEqual(result.response.count, 5)

        result = service.GetInterruptCount()
        self.assertTrue(result.status.ok())
        self.assertEqual(result.response.count, 0)

def main() -> int:
    parser = argparse.ArgumentParser()
    parser = add_device_args(parser)
    args = parser.parse_args()
    _LOG.info("Creating device_connection")

    device_connection = create_device_serial_or_socket_connection(
        device=args.device,
        baudrate=args.baudrate,
        token_databases=args.token_databases,
        compiled_protos=[marksmen_pb2],
        socket_addr=args.socket_addr,
        ticks_per_second=args.ticks_per_second,
        serial_debug=args.serial_debug,
        rpc_logging=args.rpc_logging,
        hdlc_encoding=args.hdlc_encoding,
        channel_id=args.channel_id,
        device_tracing=args.device_tracing,
        device_class=Device,
        device_tracing_class=DeviceWithTracing,
        timestamp_decoder=timestamp_parser_ms_since_boot,
    )
    with device_connection as d:
        global device
        device = d

        result = unittest.TextTestRunner().run(
            unittest.defaultTestLoader.loadTestsFromTestCase(InterruptTest)
        )
    print("\n--- Test Results ---")
    print(f"Tests run:  {result.testsRun}")
    print(f"Successful: {result.wasSuccessful()}")
    print(f"Failures:   {len(result.failures)}")
    print(f"Errors:     {len(result.errors)}")
    print(f"Skipped:    {len(result.skipped)}")
    return 0 if result.wasSuccessful() else 1

if __name__ == "__main__":
    sys.exit(main())
