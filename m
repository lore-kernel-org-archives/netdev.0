From: Piotr Hosowicz <piotr@hosowicz.com>
Subject: Re: [PATCH] r8169: fix a bug in rtl8169_init_phy()
Date: Sat, 19 Mar 2011 18:03:34 +0100
Message-ID: <4D84E1E6.1030405@example.com>
References: <4D84A46B.1000407@example.com>	<AANLkTimFGeHYEOxx=h883rRJL463g1CBUDS0wGM-52Nj@mail.gmail.com>	<1300547930.2831.27.camel@edumazet-laptop>	<201103191631.07952.oliver@neukum.org>	<1300548821.2831.28.camel@edumazet-laptop>	<1300549151.2831.32.camel@edumazet-laptop>	<4D84D098.1050802@example.com>	<1300550653.2831.34.camel@edumazet-laptop>	<4D84D956.8090407@example.com> <AANLkTim9m2A6MXBrx2QHLYNTph9mW9+BUyQpwL5QpjtB@mail.gmail.com>
Reply-To: piotr@hosowicz.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>
To: Anca Emanuel <anca.emanuel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTim9m2A6MXBrx2QHLYNTph9mW9+BUyQpwL5QpjtB@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19.03.2011 17:38, Anca Emanuel wrote:
> On Sat, Mar 19, 2011 at 6:27 PM, Piotr Hosowicz<piotr@hosowicz.com>  =
wrote:
>> On 19.03.2011 17:04, Eric Dumazet wrote:
>>>
>>> Le samedi 19 mars 2011 =C3=A0 16:49 +0100, Piotr Hosowicz a =C3=A9c=
rit :
>>>
>>>> I do not understand. I reverted the commit you mentioned and am bu=
ilding
>>>> now. Will it suffice?
>>>>
>>>
>>> Either you
>>>
>>> 1) Revert the commit
>>
>> OK. This is what I've done and everything is OK, net works as usual.=
 But
>> what should I do next? Will the revert be done on the GIT server? An=
d when?
>> I try not to clone to much and wastefuly. And am new to GIT so sorry=
 for the
>> question.
>
> Next: Test Eric's patch, and send and email with Tested-by tag.

I just built the kernel with the commit reverted as Eric said in the=20
beginning and it works. Should I build again with patching in place of=20
reverting and report it? Is the method same as ordinary patching?

Regards,

Piotr Hosowicz

--=20
Sygnaturka utworzona wy=C5=82=C4=85cznie ze zrecyklingowanych literek
najwy=C5=BCszej jako=C5=9Bci poddanych procesowi starannej selekcji.
NP: Big Big Train - The Underfall Yard
NB: 2.6.38-20110319-1638-net+
