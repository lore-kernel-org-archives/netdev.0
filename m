From: Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v3 5/5] net: asix: autoneg will set WRITE_MEDIUM reg
Date: Tue, 6 Sep 2016 09:41:53 -0700
Message-ID: <CANEJEGtE7R_FhGJfw8hayuiQi1Wbo2cYFN9MbcYzm6+Whs=2Qw@mail.gmail.com>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
 <9d5c5525f369f1c4098bda989d73886d11036bae.1472155176.git-series.robert.foss@collabora.com>
 <1472748216.5019.46.camel@edumazet-glaptop3.roam.corp.google.com>
 <18052c6d-2cb1-0927-7d33-92d4bd397aa4@collabora.com> <1472749350.5019.52.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Robert Foss <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>,
        Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>, Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org,
        Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
        Vincent Palatin <vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, Grant Grundler <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Chia-Sheng Chang <changchias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>, andrew-g2DYL2Zd6BY@public.gmane.org,
        tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org,
        "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Vincent Palatin <vpalatin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1472749350.5019.52.camel-XN9IlZ5yJG9HTL0Zs8A6p+yfmBU6pStAUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 1, 2016 at 10:02 AM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Thu, 2016-09-01 at 12:47 -0400, Robert Foss wrote:
>
>> I'm not quite sure how the first From line was added, it
>> should not have been.
>> Grant Grundler is most definitely the author.
>>
>> Would you like me to resubmit in v++ and make sure that it has been
>> corrected?
>
> This is too late, patches are already merged in David Miller net-next
> tree.
>
> These kinds of errors can not be fixed, we have to be very careful at
> submission/review time.
>
> I guess Grant does not care, but some contributors, especially new ones
> would like to get proper attribution.

I do not mind. Robert will get email about bugs instead of me. :D

cheers,
grant

>
> Thanks.
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
