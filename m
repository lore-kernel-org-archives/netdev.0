From: Piotr Hosowicz <piotr@hosowicz.com>
Subject: Re: [PATCH] r8169: fix a bug in rtl8169_init_phy()
Date: Sat, 19 Mar 2011 17:27:02 +0100
Message-ID: <4D84D956.8090407@example.com>
References: <4D84A46B.1000407@example.com>	 <AANLkTimFGeHYEOxx=h883rRJL463g1CBUDS0wGM-52Nj@mail.gmail.com>	 <1300547930.2831.27.camel@edumazet-laptop>	 <201103191631.07952.oliver@neukum.org>	 <1300548821.2831.28.camel@edumazet-laptop>	 <1300549151.2831.32.camel@edumazet-laptop>  <4D84D098.1050802@example.com> <1300550653.2831.34.camel@edumazet-laptop>
Reply-To: piotr@hosowicz.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>,
	Anca Emanuel <anca.emanuel@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300550653.2831.34.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19.03.2011 17:04, Eric Dumazet wrote:
> Le samedi 19 mars 2011 =C3=A0 16:49 +0100, Piotr Hosowicz a =C3=A9cri=
t :
>
>> I do not understand. I reverted the commit you mentioned and am buil=
ding
>> now. Will it suffice?
>>
>
> Either you
>
> 1) Revert the commit

OK. This is what I've done and everything is OK, net works as usual. Bu=
t=20
what should I do next? Will the revert be done on the GIT server? And=20
when? I try not to clone to much and wastefuly. And am new to GIT so=20
sorry for the question.

>
> OR
>
> 2) apply my patch

Regards and thanks,

Piotr Hosowicz

--=20
Jest jedna korzy=C5=9B=C4=87 z posiadania TV - jak dobrze
rozregulujesz odbiornik, trafisz na promieniowanie
mikrofalowe z pocz=C4=85tk=C3=B3w Wszech=C5=9Bwiata.
NP: Big Big Train - Master James Of St George
NB: 2.6.38-20110319-1638-net+
