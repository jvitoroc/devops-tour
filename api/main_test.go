package main

import "testing"

func Test_hello(t *testing.T) {
	type args struct {
		name string
	}
	tests := []struct {
		name string
		args args
		want string
	}{
		{
			name: "name is empty",
			args: args{
				name: "",
			},
			want: "Hello darkness, my old friend",
		},
		{
			name: "name is populated",
			args: args{
				name: "Joao",
			},
			want: "Hello Joao",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := hello(tt.args.name); got != tt.want {
				t.Errorf("hello() = %v, want %v", got, tt.want)
			}
		})
	}
}
