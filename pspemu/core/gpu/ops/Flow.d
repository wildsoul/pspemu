module pspemu.core.gpu.ops.Flow;

template Gpu_Flow() {
	auto OP_JUMP() {
		auto address = (gpu.info.baseAddress | command.param24) & (~0b_11);
		displayList.jump(gpu.memory.getPointer(address));
		//writefln("   JUMP:%08X", address);
	}

	auto OP_END() {
		displayList.end();
	}

	auto OP_FINISH() {
		glFlush();
		//gpu.storeFrameBuffer();
	}

	auto OP_CALL() {
		doassert();
	}

	auto OP_RET() {
		doassert();
	}

	auto OP_SIGNAL() {
		doassert();
	}
}