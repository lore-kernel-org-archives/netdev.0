From: Bernard Pidoux <bernard.pidoux@upmc.fr>
Subject: Re: [AX25] kernel panic
Date: Tue, 15 Sep 2009 12:16:43 +0200
Message-ID: <4AAF698B.8010608@upmc.fr>
References: <4AA82BF0.7040203@upmc.fr> <4AAAA344.4030200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <4AAAA344.4030200@gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jarek,

I was not aware of this debug option and will turn it ON.
Thanks for the suggestion.

Bernard

Jarek Poplawski a =E9crit :
> Bernard Pidoux wrote, On 09/10/2009 12:28 AM:
>
>  =20
>> Hi Ralf,
>>
>> Here is a set of not so frequent kernel panics captured via netconso=
le
>> that seem related to AX25 timer.=20
>>
>> Regards,
>>
>> Bernard Pidoux
>>
>>    =20
>
> Hi Bernard,
>
> Could/did you try to turn on this debugging option below, btw?
>
> Regards,
> Jarek P.
>
>    CONFIG_DEBUG_OBJECTS_TIMERS:
>   ?                                                                  =
                                      ? =20
>   ? If you say Y here, additional code will be inserted into the     =
                                      ? =20
>   ? timer routines to track the life time of timer objects and       =
                                      ? =20
>   ? validate the timer operations.                                   =
                                      ? =20
>   ?                                                                  =
                                      ? =20
>   ? Symbol: DEBUG_OBJECTS_TIMERS [=3Dy]                              =
                                        ? =20
>   ? Prompt: Debug timer objects                                      =
                                      ? =20
>   ?   Defined at lib/Kconfig.debug:247                               =
                                      ? =20
>   ?   Depends on: DEBUG_OBJECTS                                      =
                                      ? =20
>   ?   Location:                                                      =
                                      ? =20
>   ?     -> Kernel hacking                                            =
                                      ? =20
>   ?       -> Kernel debugging (DEBUG_KERNEL [=3Dy])                  =
                                        ? =20
>   ?         -> Debug object operations (DEBUG_OBJECTS [=3Dy])        =
                                        ? =20
>   ?                                                                  =
   =20
>
>  =20

--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
