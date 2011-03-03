From: Tianji Li <Tianji.Li-4eIRXPAgDeg@public.gmane.org>
Subject: Re: ANNOUNCE: debloat-testing kernel git tree
Date: Thu, 03 Mar 2011 13:45:24 -0600
Message-ID: <4D6FEFD4.9010608@nuim.ie>
References: <20110225222210.GA3618@tuxdriver.com>
 <AANLkTingkcc-dvs_8Nr0vYXdXvuDHEn6sz14tnHzLp8W@mail.gmail.com>
 <87fwr9jxya.fsf@cruithne.co.teklibre.org>
 <AANLkTinpG-xAC-VV-j7EBJB522+BqCyyFd_6N3KEr2Cf@mail.gmail.com>
 <8739n9ii7z.fsf@cruithne.co.teklibre.org>
 <AANLkTi=Cp7N4xqPyU6KWF6DOzFytxaA2BeoXhnhsZ6dp@mail.gmail.com>
 <87tyfph2az.fsf@cruithne.co.teklibre.org> <1299176168.2157.14.camel@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Dave_T=E4ht?= <d@taht.net>, sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bloat-devel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: rick.jones2-VXdhtT5mjnY@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <1299176168.2157.14.camel@tardy>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 03/03/2011 12:16 PM, Rick Jones wrote:
>> For wireless routers and cable home gateways especially, this research
>> shows that the total un-managed buffers in your system should be less
>> than 32.
>
> Would it be a good thing to start describing these queues not so much in
> terms of packets but in terms of delay (or bandwidth X delay)?
>

The unit of bandwidth is something like Mbps, that of delay can be 
second, so bandwidth X delay --> Mb, which is the unit of packet size. 
So both packets and delay should have the same effect for sizing buffers.

Tianji



> Constants tend to live longer than they should, no matter how noble in
> birth.
>
> rick jones
>
> _______________________________________________
> Bloat-devel mailing list
> Bloat-devel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
> https://lists.bufferbloat.net/listinfo/bloat-devel
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
