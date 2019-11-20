class Courses {
  final String courseName;
  final String program;
  final String sem;
  final int semesterId;

  Courses({
    this.courseName,
    this.program,
    this.sem,
    this.semesterId,
  });
  factory Courses.fromJson(Map<String, dynamic> json) {
    return Courses(
      semesterId: json['semester_id'],
      courseName: json['course_name'],
      program: json['program_name'],
      sem: json['sem'],
    );
  }
}
