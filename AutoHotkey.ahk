; See https://gist.github.com/sedm0784/4443120
SetCapsLockState, AlwaysOff
g_LastCapsLockKeyDownTime := 0
g_CapsLockRepeatDetected := false

g_LastEnterKeyDownTime := 0
g_EnterRepeatDetected := false

g_AbortSend := false
g_Timeout := 250

*CapsLock::
    if (g_CapsLockRepeatDetected)
    {
        return
    }

    send,{Ctrl down}
    g_LastCapsLockKeyDownTime := A_TickCount
    g_AbortSend := false
    g_CapsLockRepeatDetected := true
    return

*CapsLock Up::
    send,{Ctrl up}
    g_CapsLockRepeatDetected := false
    if (g_AbortSend)
    {
        return
    }
    current_time := A_TickCount
    time_elapsed := current_time - g_LastCapsLockKeyDownTime
    if (time_elapsed <= g_Timeout)
    {
        SendInput {Esc}
    }
    return

*Enter::
    if (g_EnterRepeatDetected)
    {
        return
    }

    send,{Ctrl down}
    g_LastEnterKeyDownTime := A_TickCount
    g_AbortSend := false
    g_EnterRepeatDetected := true
    return

*Enter Up::
    send,{Ctrl up}
    g_EnterRepeatDetected := false
    if (g_AbortSend)
    {
        return
    }
    current_time := A_TickCount
    time_elapsed := current_time - g_LastEnterKeyDownTime
    if (time_elapsed <= g_Timeout)
    {
        SendInput {Enter}
    }
    return

*^Enter::
    if (g_EnterRepeatDetected)
    {
        return
    }
    g_AbortSend := true
    SendInput ^{Enter}
~*^a::
    g_AbortSend := true
    return
~*^b::
    g_AbortSend := true
    return
~*^c::
    g_AbortSend := true
    return
~*^d::
    g_AbortSend := true
    return
~*^e::
    g_AbortSend := true
    return
~*^f::
    g_AbortSend := true
    return
~*^g::
    g_AbortSend := true
    return
~*^h::
    g_AbortSend := true
    return
~*^i::
    g_AbortSend := true
    return
~*^j::
    g_AbortSend := true
    return
~*^k::
    g_AbortSend := true
    return
~*^l::
    g_AbortSend := true
    return
~*^m::
    g_AbortSend := true
    return
~*^n::
    g_AbortSend := true
    return
~*^o::
    g_AbortSend := true
    return
~*^p::
    g_AbortSend := true
    return
~*^q::
    g_AbortSend := true
    return
~*^r::
    g_AbortSend := true
    return
~*^s::
    g_AbortSend := true
    return
~*^t::
    g_AbortSend := true
    return
~*^u::
    g_AbortSend := true
    return
~*^v::
    g_AbortSend := true
    return
~*^w::
    g_AbortSend := true
    return
~*^x::
    g_AbortSend := true
    return
~*^y::
    g_AbortSend := true
    return
~*^z::
    g_AbortSend := true
    return
~*^1::
    g_AbortSend := true
    return
~*^2::
    g_AbortSend := true
    return
~*^3::
    g_AbortSend := true
    return
~*^4::
    g_AbortSend := true
    return
~*^5::
    g_AbortSend := true
    return
~*^6::
    g_AbortSend := true
    return
~*^7::
    g_AbortSend := true
    return
~*^8::
    g_AbortSend := true
    return
~*^9::
    g_AbortSend := true
    return
~*^0::
    g_AbortSend := true
    return
~*^Space::
    g_AbortSend := true
    return
~*^Backspace::
    g_AbortSend := true
    return
~*^Delete::
    g_AbortSend := true
    return
~*^Insert::
    g_AbortSend := true
    return
~*^Home::
    g_AbortSend := true
    return
~*^End::
    g_AbortSend := true
    return
~*^PgUp::
    g_AbortSend := true
    return
~*^PgDn::
    g_AbortSend := true
    return
~*^Tab::
    g_AbortSend := true
    return
~*^,::
    g_AbortSend := true
    return
~*^.::
    g_AbortSend := true
    return
~*^/::
    g_AbortSend := true
    return
~*^;::
    g_AbortSend := true
    return
~*^'::
    g_AbortSend := true
    return
~*^[::
    g_AbortSend := true
    return
~*^]::
    g_AbortSend := true
    return
~*^\::
    g_AbortSend := true
    return
~*^-::
    g_AbortSend := true
    return
~*^=::
    g_AbortSend := true
    return
~*^`::
    g_AbortSend := true
    return
~*^F1::
    g_AbortSend := true
    return
~*^F2::
    g_AbortSend := true
    return
~*^F3::
    g_AbortSend := true
    return
~*^F4::
    g_AbortSend := true
    return
~*^F5::
    g_AbortSend := true
    return
~*^F6::
    g_AbortSend := true
    return
~*^F7::
    g_AbortSend := true
    return
~*^F8::
    g_AbortSend := true
    return
~*^F9::
    g_AbortSend := true
    return
~*^F10::
    g_AbortSend := true
    return
~*^F11::
    g_AbortSend := true
    return
~*^F12::
    g_AbortSend := true
    return
