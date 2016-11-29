package body Math is

   function "+" (A : Vecteur ; B : Vecteur) return Vecteur is
      R : Vecteur(A'Range);
   begin
      for I in A'Range loop
          R(I) := A(I) + B(I);
      end loop;
      return R;
   end;

   function "*" (Facteur : Float ; V : Vecteur) return Vecteur is
      R : Vecteur(V'Range);
   begin
      for I in V'Range loop
          R(I) := Facteur * V(I);
      end loop;
      return R;
   end;

   procedure Bezier(P1, C1, C2, P2 : Point2D ; Nb_Points : Positive ;
                    Points : out Liste) is
      T : Float := 0.0;
   begin
      while T < 1.0 loop
          Insertion_Queue(Points, ((1.0 - T)**3)*P1 + 3.0*T*((1.0 - T)**2)*C1 + 3.0*(T**2)*(1.0 - T)*C2 + (T**3)*P2);
          T := T + (1.0 / Float(Nb_Points));
      end loop;
   end;

   procedure Bezier(P1, C, P2 : Point2D ; Nb_Points : Positive ;
                    Points : out Liste) is
      T : Float := 0.0;
   begin
      while T < 1.0 loop
          Insertion_Queue(Points, ((1.0 - T)**2)*P1 + 2.0*T*(1.0 - T)*C + (T**2)*P2);
          T := T + (1.0 / Float(Nb_Points));
      end loop;
   end;
end;
