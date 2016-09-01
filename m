From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 5/5] net: asix: autoneg will set WRITE_MEDIUM reg
Date: Thu, 01 Sep 2016 10:02:30 -0700
Message-ID: <1472749350.5019.52.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
         <9d5c5525f369f1c4098bda989d73886d11036bae.1472155176.git-series.robert.foss@collabora.com>
         <1472748216.5019.46.camel@edumazet-glaptop3.roam.corp.google.com>
         <18052c6d-2cb1-0927-7d33-92d4bd397aa4@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org, Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org,
        Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
        stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
        changchias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
        tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vpalatin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: Robert Foss <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <18052c6d-2cb1-0927-7d33-92d4bd397aa4-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-09-01 at 12:47 -0400, Robert Foss wrote:

> I'm not quite sure how the first From line was added, it
> should not have been.
> Grant Grundler is most definitely the author.
> 
> Would you like me to resubmit in v++ and make sure that it has been 
> corrected?

This is too late, patches are already merged in David Miller net-next
tree.

These kinds of errors can not be fixed, we have to be very careful at
submission/review time.

I guess Grant does not care, but some contributors, especially new ones
would like to get proper attribution.

Thanks.


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
