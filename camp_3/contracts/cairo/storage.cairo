%lang starknet

# starknet-compile storage.cairo --output storage_compiled.json
# starknet deploy --gateway_url http://localhost:5050 --contract storage_compiled.json
from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
# from starkware.starknet.common.syscalls import storage_read, storage_write
from starkware.starknet.common.syscalls import storage_read

const SINGLE_KEY = 0x259a7ae4e23df025d5bead0bbd3eb2b756283fc3088b592e179533be7dd1251
const MULTI_KEY = 0x12871215cdec46a1b610066e09151ccd5eed3824ebe4ba02596c69361a2f91
const STRUCT_KEY = 0x1f071b583a1f24f97d31c8451c71ff92a697bc29fdbbee219fd19d325703adf

struct Custom:
    member left : felt
    member center : felt
    member right : felt
end

#
# '@storage_var' decorator declares a variable that will be kept as part of the contract storage
#   - can consist of a single felt, or map to custom types(tuple, structs)
#   - '.read' and '.write' utility functions are created automatically for storage variables
#
@storage_var
func single_store() -> (res : felt):
end

@storage_var
func multi_store() -> (res : (left : felt, right : felt)):
end

@storage_var
func struct_store() -> (res : Custom):
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    single_store.write(123)
    multi_store.write((left=456, right=789))
    struct_store.write(Custom(left=101112, center=131415, right=161718))

    return ()
end

#
# '@view' functions can be used to read contract storage
#
@view
func get_single_store{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (value : felt):
    let (value) = single_store.read()
    return (value)
end

@view
func get_multi_store{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (value : (left : felt, right : felt)):
    let (value) = multi_store.read()
    return (value)
end

@view
func get_struct_store{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (value : Custom):
    let (value) = struct_store.read()
    return (value)
end

#
# direct storage access for demonstration purposes
#
@view
func get_single_store_literal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (value : felt):
    let (value) = storage_read(SINGLE_KEY)
    return (value)
end

@view
func get_multi_store_literal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (value : (left : felt, right : felt)):
    let (left) = storage_read(MULTI_KEY)
    let (right) = storage_read(MULTI_KEY+1)

    return ((left, right))
end

@view
func get_struct_store_literal{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (value : Custom):
    let (left) = storage_read(STRUCT_KEY)
    let (center) = storage_read(STRUCT_KEY+1)
    let (right) = storage_read(STRUCT_KEY+2)

    return (Custom(left, center, right))
end