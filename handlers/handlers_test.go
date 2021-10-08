package handlers

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

// TODO: Add defer cleanup

func TestIndex(t *testing.T) {
	request, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(Index)
	handler.ServeHTTP(rr, request)

	assert.Equal(t, http.StatusOK, rr.Code)
	assert.Equal(t, "Hello World Set Node\n", rr.Body.String())
}

func TestAdd(t *testing.T) {
	defer testClearUtil(t)
	testAddUtil(t, "1", http.StatusOK)
}

func TestAdd_NonNumberElement(t *testing.T) {
	defer testClearUtil(t)
	testAddUtil(t, "+", http.StatusInternalServerError)
}

func TestAdd_DuplicateElement(t *testing.T) {
	defer testClearUtil(t)
	testAddUtil(t, "1", http.StatusOK)
	testAddUtil(t, "1", http.StatusOK)
}

func TestGet(t *testing.T) {
	defer testClearUtil(t)
	testAddUtil(t, "1", http.StatusOK)
	testGetUtil(t, "[1]\n", http.StatusOK)
}

func TestGet_NonNumberElement(t *testing.T) {
	defer testClearUtil(t)
	testAddUtil(t, "+", http.StatusInternalServerError)
	testGetUtil(t, "[]\n", http.StatusOK)
}

func TestGet_EmptyElement(t *testing.T) {
	defer testClearUtil(t)
	testGetUtil(t, "[]\n", http.StatusOK)
}

func TestGet_DuplicateElement(t *testing.T) {
	defer testClearUtil(t)
	testAddUtil(t, "1", http.StatusOK)
	testAddUtil(t, "1", http.StatusOK)
}

func testAddUtil(t *testing.T, element string, expectedStatus int) {
	payload := fmt.Sprintf(`{"value": "%s"}`, element)

	request, err := http.NewRequest("POST", "/set/add", strings.NewReader(payload))
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(Add)
	handler.ServeHTTP(rr, request)

	assert.Equal(t, expectedStatus, rr.Code)
}

func testGetUtil(t *testing.T, expectedList string, expectedStatus int) {
	request, err := http.NewRequest("GET", "/set/list", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(List)
	handler.ServeHTTP(rr, request)

	assert.Equal(t, expectedStatus, rr.Code)
	assert.Equal(t, expectedList, rr.Body.String())
}

func testClearUtil(t *testing.T) {
	request, err := http.NewRequest("GET", "/set/debug/clear", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(Clear)
	handler.ServeHTTP(rr, request)

	assert.Equal(t, http.StatusOK, rr.Code)
	testGetUtil(t, "[]\n", http.StatusOK)
}
