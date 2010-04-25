From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [2.6.34-rc5-git6] EIP: is at inet6_csk_bind_conflict + 06xe/0xb7
	[ipv6]
Date: Sun, 25 Apr 2010 19:25:44 +0200
Message-ID: <x2t2d0a357f1004251025q5a284b0fwa351f762acdf62e4@mail.gmail.com>
References: <l2z2d0a357f1004250811w6da355ebp95d1730473026c22@mail.gmail.com>
	 <4BD45E68.4080900@example.com>
	 <g2z2d0a357f1004250931pf5880c60l32fd0643e0f14bde@mail.gmail.com>
	 <4BD46F9C.5060500@example.com>
	 <1272213597.2069.32.camel@edumazet-laptop>
	 <j2p2d0a357f1004250955i59969a2cp9fd9eb9f3ef22d4b@mail.gmail.com>
	 <4BD4757E.8020503@example.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jiri Olsa <jolsa@redhat.com>,
	Jongman Heo <jongman.heo@gmail.com>
To: piotr@hosowicz.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BD4757E.8020503@example.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 25, 2010 at 7:01 PM, Piotr Hosowicz <piotr@hosowicz.com> wr=
ote:
> On 25.04.2010 18:55, Sedat Dilek wrote:
>>
[...]
>> On Sun, Apr 25, 2010 at 6:39 PM, Eric Dumazet<eric.dumazet@gmail.com=
>
>> =C2=A0wrote:
>>>
>>> Le dimanche 25 avril 2010 =C3=A0 18:36 +0200, Piotr Hosowicz a =C3=A9=
crit :
>>>>
>>>> On 25.04.2010 18:31, Sedat Dilek wrote:
>>>>>
>>>>> [ CCing netdev ML ]
>>>>>
>>>>> Confirmed: The revert-patch [1] fixes the problem here.
>>>>
>>>> I confirm, I've built a git6 kernel and it works fine.
>>>>
>>>>> See also "Bug 15847 - =C2=A0crash in inet6_csk_bind_conflict" [2]=
=2E
>>>>>
>>>>> Feel free to add a... Tested-by: Sedat Dilek<sedat.dilek@gmail.co=
m>
>>>>
>>>> I added created and tested phrase in my archive. ;-) Thank you a l=
ot. I
>>>> hope there will be no this error in git7.
>>>>
>>>
>>> Did you test the proposed fix ?
>
> Eric, but where to get the proposed fix as a patch? I looked at kerne=
l's
> bugzilla and there is no such thing. As for now I applied Sedat's rev=
erse
> patch and now I am booted fine in git6 kernel.
>
> Regards,
>
> Piotr Hosowicz
>

=46or easy catching proposed patched to LKML look at <patchwork.kernel.=
org> [1].
There you find other mailing-lists and further patches.
Cut-N-Paste excerpts of Eric's email should also work :-).

- Sedat -

[1] https://patchwork.kernel.org/project/LKML/list/
[2] https://patchwork.kernel.org/patch/94961/
