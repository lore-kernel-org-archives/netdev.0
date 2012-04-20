From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: net-next iwlwifi breaks compile - was Re: pull request: wireless-next
 2012-04-18
Date: Fri, 20 Apr 2012 07:18:59 +0200
Message-ID: <4F90F1C3.8020604@hartkopp.net>
References: <20120418.153653.2130740499995307564.davem@davemloft.net> <4F8F9977.9040703@hartkopp.net> <4595B4D22AB93C4FABBA84AAD5AA37FD1258AA@ORSMSX103.amr.corp.intel.com> <20120419.154954.1322943404183128381.davem@davemloft.net> <4595B4D22AB93C4FABBA84AAD5AA37FD1259E6@ORSMSX103.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Guy, Wey-Yi W" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Spinadel, David" <david.spinadel-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: "Venkataraman, Meenakshi" <meenakshi.venkataraman-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4595B4D22AB93C4FABBA84AAD5AA37FD1259E6-P5GAC/sN6hlQxe9IK+vIArfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thanks guys!

I just pulled net-next and it's compiling properly now.

Regards,
Oliver

On 19.04.2012 23:07, Venkataraman, Meenakshi wrote:

> Hi David,
> 
>>> It was fixed internally in a subsequent patch, but that patch has not
>>> made it into net-next. I don't see it in the public iwlwifi repository
>>> either. We'll add the fix to the repository so you can pick it up.
>>
>> That's not how this works.
>>
>> You should submit a patch to fix the build directly to me, immediately, so that I
>> can push it directly into net-next as fast as possible.
> 
> [MV]  Okay -- this is good to know. Essentially -- if any upstream tree breaks due to our work, then a fix should be directly submitted ASAP to the maintainer of that tree.
> 
> I see that Wey-Yi has already sent you the fix, so nothing left for me to do on this one.
> 
> Thanks,
> Meenakshi


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
