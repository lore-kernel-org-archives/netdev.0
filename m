From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [3.1-rc8 REGRESSION] sky2 hangs machine on turning off or suspending
Date: Wed, 23 Nov 2011 09:16:49 +0100
Message-ID: <CACna6rzwsLGWXCwn9uuUBmA_nvNN2C_KRyaOoDWT47V+qB=96A@mail.gmail.com>
References: <CACna6ryTdLcWVYgHu=_mRFga1sFivpE_DyZOY-HMmKggkWAJAw@mail.gmail.com>
	<CACna6rwDjqwypAr_03NEA=x8J_2DpL2LjgSMiQmLHHGv3AA7GA@mail.gmail.com>
	<1322035395.1298.50.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1322035395.1298.50.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

W dniu 23 listopada 2011 09:03 u=C5=BCytkownik Eric Dumazet
<eric.dumazet@gmail.com> napisa=C5=82:
> Le mercredi 23 novembre 2011 =C3=A0 08:43 +0100, Rafa=C5=82 Mi=C5=82e=
cki a =C3=A9crit :
>
>> The bug was resolved by:
>> sky2: fix hang in napi_disable
>>
>> Stephen, two comments to you:
>>
>> 1) I really hoped to get some info about resolving this issue. You
>> could just ping me that something worth testing was posted.
>>
>
> I agree 100%, I am verry sorry this happened.
>
> Stephen, we must show toal respect to bug reporters, they do their pa=
rt
> of the job.
>
> We need more bug reports :)
>
> A "Reported-by:" tag is mandatory, not counting a CC on mails
>
> As Rafal spent incredible time to bisect the bug, another tag is welc=
ome
> as well :
>
> "Bisected-by:" ...
>
> This takes maybe 20 seconds, while the bug fix took far more...

Nice we agree, thanks :) You know, it can be a little confusing when
you don't get any feedback for almost 2 weeks.


>> 2) Update your e-mail address in MAINTAINERS please.
>>
>
> What do you mean, it seems OK to me (Stephen Hemminger
> <shemminger@vyatta.com>) ?

Ah, so it was already updated, OK :)

In some linville's tree I saw address at linux-foundation.org domain
which doesn't work.


Thanks for your work and for the driver! :)

--=20
Rafa=C5=82
