From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Is this 32-bit NCM?y
Date: Thu, 4 Dec 2014 10:28:27 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1412041027360.3613@gmail.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com> <B315C8AC-3B33-406B-A728-14F8FAAAE986@audiocodes.com> <547D37CA.7050506@audiocodes.com> <alpine.LNX.2.03.1412020729470.1351@gmail.com> <547D5F84.6020608@audiocodes.com> <alpine.LNX.2.03.1412020747360.1921@gmail.com>
 <547D6D7B.5090704@audiocodes.com> <E0C3DF2A36210C42B1AB4626A0E10F1FD949424C@aclmbx01.corp.audiocodes.com> <547D7243.80508@audiocodes.com> <alpine.LNX.2.03.1412021130410.2697@gmail.com> <87fvcyqoup.fsf@nemi.mork.no> <alpine.LNX.2.03.1412021410270.29633@gmail.com>
 <87lhmqp400.fsf@nemi.mork.no> <alpine.LNX.2.03.1412021453340.7488@gmail.com> <1417532733483.89987@audiocodes.com> <alpine.LNX.2.03.1412021627360.8131@gmail.com> <547EA1D1.8010202@audiocodes.com> <alpine.LNX.2.03.1412030659001.1288@gmail.com>
 <547EA82F.5050500@audiocodes.com> <alpine.LNX.2.03.1412040730480.1320@gmail.com> <548020DD.3030705@audiocodes.com> <874mtbojqo.fsf@nemi.mork.no> <548028A0.5000909@audiocodes.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1019746673-1417685308=:3613"
Cc: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Midge Shaojun Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	"youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <548028A0.5000909-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1019746673-1417685308=:3613
Content-Type: TEXT/PLAIN; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8BIT

Ok - but... you can upgrade your OS to that without any effort - simply apt-get-installing the required linux-image-3.16 package plus the -extra package. It's nothing more in case.
thank you kevin, thank you Bjorn.

Enrico



On Thu, 4 Dec 2014, Kevin Zhu wrote:

> Date: Thu, 4 Dec 2014 10:26:20
> From: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
> To: Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> Cc: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>     Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
>     Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>     Midge Shaojun  Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
>     "youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
>     "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
>     "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
> Subject: Re: Is this 32-bit NCM?y
> 
> I will find it out. And I don't have v3.16 and I'm not going to upgrade
> my OS to that. Sorry. So I would just stick to v3.13. Anyway, that size
> is wrong, it should be fixed.
>
> Regards,
> Kevin
>
> On 12/04/2014 05:19 PM, Bjørn Mork wrote:
>> Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org> writes:
>>
>>> Guys,
>>>
>>> After rearranging the padding, putting NCM0 right after NTH, and disable
>>> ARP (FLAG_NOARP) and handling the offset alignment issue, it seems it
>>> begins to work, though there's still problem with DHCP.
>> Great!  But it would be good to know if _one_ of these changes is enough
>> to make it work.
>>
>>> The DHCP packet's size becomes a large one after the TX function, which
>>> is 16384, the maximum.
>> You can now (from v3.16) disable the padding by setting min_tx_pkt >= tx_max.
>> Something like this should do for a simple test:
>>
>>   echo 16384 >/sys/class/net/wwan0/cdc_ncm/min_tx_pkt
>>
>>
>> Bjørn
> This email and any files transmitted with it are confidential material. They are intended solely for the use of the designated individual or entity to whom they are addressed. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, use, distribution or copying of this communication is strictly prohibited and may be unlawful.
>
> If you have received this email in error please immediately notify the sender and delete or destroy any copy of this message
>
--8323328-1019746673-1417685308=:3613--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
