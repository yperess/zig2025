"""Wraps pw_system's console to inject additional RPC protos."""

import sys

from pw_protobuf_protos import common_pb2
from pw_rpc import echo_pb2
import pw_system.console
# from proto import zig2025_demo_pb2


def main() -> int:
    """Start the console"""
    compiled_protos = [common_pb2, echo_pb2]
    # compiled_protos += [zig2025_demo_pb2]
    return pw_system.console.main_with_compiled_protos(compiled_protos)


if __name__ == '__main__':
    sys.exit(main())
