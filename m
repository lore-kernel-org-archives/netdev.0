From: Anca Emanuel <anca.emanuel@gmail.com>
Subject: Re: [PATCH] r8169: fix a bug in rtl8169_init_phy()
Date: Sat, 19 Mar 2011 18:38:07 +0200
Message-ID: <AANLkTim9m2A6MXBrx2QHLYNTph9mW9+BUyQpwL5QpjtB@mail.gmail.com>
References: <4D84A46B.1000407@example.com>
	<AANLkTimFGeHYEOxx=h883rRJL463g1CBUDS0wGM-52Nj@mail.gmail.com>
	<1300547930.2831.27.camel@edumazet-laptop>
	<201103191631.07952.oliver@neukum.org>
	<1300548821.2831.28.camel@edumazet-laptop>
	<1300549151.2831.32.camel@edumazet-laptop>
	<4D84D098.1050802@example.com>
	<1300550653.2831.34.camel@edumazet-laptop>
	<4D84D956.8090407@example.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>
To: piotr@hosowicz.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D84D956.8090407@example.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 19, 2011 at 6:27 PM, Piotr Hosowicz <piotr@hosowicz.com> wr=
ote:
> On 19.03.2011 17:04, Eric Dumazet wrote:
>>
>> Le samedi 19 mars 2011 =E0 16:49 +0100, Piotr Hosowicz a =E9crit :
>>
>>> I do not understand. I reverted the commit you mentioned and am bui=
lding
>>> now. Will it suffice?
>>>
>>
>> Either you
>>
>> 1) Revert the commit
>
> OK. This is what I've done and everything is OK, net works as usual. =
But
> what should I do next? Will the revert be done on the GIT server? And=
 when?
> I try not to clone to much and wastefuly. And am new to GIT so sorry =
for the
> question.

Next: Test Eric's patch, and send and email with Tested-by tag.
