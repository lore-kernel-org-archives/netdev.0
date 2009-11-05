From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH RFC] TCPCT part 1d: generate Responder	Cookie
Date: Thu, 05 Nov 2009 14:44:37 -0500
Message-ID: <4AF32B25.4000700@gmail.com>
References: <4AEAC763.4070200@gmail.com> <4AED86AD.6010906@gmail.com> <4AEDCD7C.2010403@gmail.com> <4AF0B0D2.4030905@gmail.com> <20091104214844.GA6714@linux.vnet.ibm.com> <4AF2C266.1010603@gmail.com> <4AF2D0E0.1040903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758805AbZKEToj@vger.kernel.org>
In-Reply-To: <4AF2D0E0.1040903@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> William Allen Simpson a =E9crit :
>> As you suggest, I'll use the _bh suffix everywhere until every i is =
dotted
>> and t is crossed.  Then, check for efficiency later after thorough
>> analysis by experts such as yourself.
>>
>> This code will be hit on every SYN and SYNACK that has a cookie opti=
on.
>> But it's just prior to a CPU intensive sha_transform -- in compariso=
n,
>> it's trivial.
>>
> I think you misunderstood my advice ;)
>=20
Yes, I misunderstood, but it's clear now.  As I have to re-spin the who=
le
kit and kaboodle after the recent net-next crashing bug fixes, I'll pos=
t
another complete set tomorrow to the net list.

Thanks again (for all messages).
