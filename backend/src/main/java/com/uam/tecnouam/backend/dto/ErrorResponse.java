package com.uam.tecnouam.backend.dto;

import java.time.Instant;
import java.util.Map;

public class ErrorResponse {

    private Instant timestamp = Instant.now();
    private int status;
    private String error;
    private String message;
    private Map<String, String> detalles;

    public ErrorResponse(int status, String error, String message) {
        this.status = status;
        this.error = error;
        this.message = message;
    }

    public ErrorResponse(int status, String error, String message, Map<String, String> detalles) {
        this(status, error, message);
        this.detalles = detalles;
    }

    public Instant getTimestamp() {
        return timestamp;
    }

    public int getStatus() {
        return status;
    }

    public String getError() {
        return error;
    }

    public String getMessage() {
        return message;
    }

    public Map<String, String> getDetalles() {
        return detalles;
    }
}
