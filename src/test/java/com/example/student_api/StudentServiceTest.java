package com.example.student_api;

import org.junit.jupiter.api.Test;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class StudentServiceTest {

    @Test
    void getStudentByIdReturnsExistingStudent() {
        StudentRepository repository = mock(StudentRepository.class);
        Student student = new Student();
        student.setId(1L);
        student.setName("Ali");
        student.setEmail("ali@example.com");
        student.setAge(20);

        when(repository.findById(1L)).thenReturn(Optional.of(student));

        StudentService service = new StudentService(repository);

        Student result = service.getStudentById(1L);

        assertEquals(student, result);
    }
}
