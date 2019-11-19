class Event {
	boolean finished = false;
	boolean spawned = false;
	float time;
	float timeEnd;

	Event() {}

	Event(float time, float timeEnd) {
		this.time = time;
		this.timeEnd = timeEnd;
	}

	void spawn() {}
	
	void update() {}

	void end() {}
}