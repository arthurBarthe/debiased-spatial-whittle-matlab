function b = copyobj(a)
   b = eval(class(a));  %create default object of the same class as a. one valid use of eval
   for p =  properties(a).'  %copy all public properties
      try   %may fail if property is read-only
         b.(p) = a.(p);
      catch
         error('failed to copy property: %s');
      end
   end
end

