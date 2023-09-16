module tools;

// generating switch
template GenerateSwitch()
{
    template GenerateSwitchBody(tpairs...)
    {
        static if(tpairs.length > 0)
        {
            enum GenerateSwitchBody = 
                "case("~to!string(tpairs[0])~
                "): return cast(Message)(func!(SerializerBackend, "~
                tpairs[1].stringof~")(args)); break; \n" ~
                GenerateSwitchBody!(tpairs[2..$]);
        } 
        else
            enum GenerateSwitchBody = "";
    }
    enum GenerateSwitch = "switch(id)\n{\n"~
        GenerateSwitchBody!(pairs) ~ "default: " ~
        " break;\n}";

}
