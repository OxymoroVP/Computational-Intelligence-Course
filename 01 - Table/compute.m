function y = compute(time,initial_vector,A,B,C,controller,ke,kd,k1,input)

    T = 0.01;
    u_prev = 0;
    y_prev = 0;
    e_prev = 1;

    y = zeros(length(time), 1);
    x = initial_vector;

    for i = 1:length(time)
        t = time(i);
        r = input(t);

        e = (r - y_prev) / 50;
        de = (e - e_prev);
        e_prev = e;

        in1 = max(min(ke*e, 1), -1);
        in2 = max(min(kd*de / T, 1), -1);

        out = k1*T*evalfis(controller, [in1, in2])*50;
        u_prev = u_prev + out;

        x = x + T*(A*x + B*u_prev);
        y(i) = C*x;
        y_prev = y(i);
    end
end
