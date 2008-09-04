From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: [GIT]: Networking
Date: Thu, 04 Sep 2008 05:35:28 -0400
Message-ID: <48BFABE0.6050505@garzik.org>
References: <20080903.161341.239039051.davem@davemloft.net> <alpine.LFD.1.10.0809031621160.3515@nehalem.linux-foundation.org> <20080903.162603.27086959.davem@davemloft.net> <200809041025.15277.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Ayaz Abdulla <aabdulla-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200809041025.15277.rjw-KKrjLPT3xs0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Rafael J. Wysocki wrote:
> On Thursday, 4 of September 2008, David Miller wrote:
>> From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
>> Date: Wed, 3 Sep 2008 16:24:16 -0700 (PDT)
>>
>>> On Wed, 3 Sep 2008, Linus Torvalds wrote:
>>>> What's so hard to understand about this?
>>> Here's a simple rule of thumb:
>>>  - if it's not on the regression list
>>>  - if it's not a reported security hole
>>>  - if it's not on the reported oopses list
>>> then why are people sending it to me?
>>>
>>> IOW, if it's just another random improvement, and you send it to me 
>>> outside of the merge window, then what is the point of the merge window? 
>> This is exactly what I've been trying to tell the Intel wireless folks
>> but they refuse to listen.
>>
>> I just won't take their stuff until they get their act in gear.
>>
>> No problem.
> 
> BTW, there are two regression fixes for forcedeth:
> 
> http://marc.info/?l=linux-kernel&m=121894389018584&w=4
> http://marc.info/?l=linux-kernel&m=121917167232014&w=4
> 
> that fix the regressions tracked as:
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=11358
> http://bugzilla.kernel.org/show_bug.cgi?id=11361
> 
> respectively and both are more than 2 weeks old now.
> 
> Is there any chance to push them upstream or is there anything wrong with them?

Your patch is fine.  Since DaveM and I are gone this weekend, feel free 
to add "acked-by: jgarzik@redhat" and forward upstream to Linus and Andrew.

I thought there was some discussion about Yinghai Lu's MAC addr patch, 
though.  I'll look into it Monday, but maybe Ayaz (maintainer @ nv) 
could ack it sooner than that?

	Jeff



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
