From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RESEND PATCH v1 0/4] Add support emac for the RK3036 SoC platform
Date: Tue, 29 Dec 2015 14:56:24 -0800
Message-ID: <20898DB3-4FB5-4130-A69D-1DE4BC819A5C@gmail.com>
References: <1451287341-16453-1-git-send-email-zhengxing@rock-chips.com> <20151229.155314.1522114236952280828.davem@davemloft.net> <3925713.yDzK1dvrIv@diego>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, leozwang-hpIqsD4AKlcxg7vii5yOFA@public.gmane.org, linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
	pawel.moll-5wv7dgnIgG8@public.gmane.org, geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: =?ISO-8859-1?Q?Heiko_St=FCbner?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <3925713.yDzK1dvrIv@diego>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On December 29, 2015 2:27:55 PM PST, "Heiko St=C3=BCbner" <heiko@sntech=
=2Ede> wrote:
>Hi Dave,
>
>Am Dienstag, 29. Dezember 2015, 15:53:14 schrieb David Miller:
>> You have to submit this series properly, the same problem happend
>twice
>> now.
>>=20
>> When you submit a series you should:
>>=20
>> 1) Make it clear which tree you expect these changes to be applied
>>    to.  Here it is completely ambiguous, do you want it to go into
>>    my networking tree or some other subsystem tree?
>>=20
>> 2) You MUST keep all parties informed about all patches for a series
>>    like this.  That means you cannot drop netdev from patch #4 as
>>    you did both times.  Doing this aggravates the situation for
>>    #1 even more, because if a patch is not CC:'d to netdev it does
>>    not enter patchwork.  And if it doesn't go into patchwork, I'm
>>    not looking at it.
>
>I guess that is some unfortunate result of git send-email combined wit=
h
>
>get_maintainer.pl . In general I also prefer to see the whole series,
>but have=20
>gotten such partial series from other maintainers as well in the past,
>so it=20
>seems to be depending on preferences somewhat.

You could run get_maintainer.pl against the individual patches in the s=
eries, merge the cc list somewhere in a file/variable and then do the a=
ctual mail submission with that full list for all patches. There could =
be a way to automate that with a bit of help from git send-email eventu=
ally.

--=20
=46lorian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
