From: Gene Heskett <gene.heskett-H+0wwilmMs3R7s880joybQ@public.gmane.org>
Subject: Re: [RFC PATCH] bcm43xx: set channel when the interface is brought up
Date: Thu, 25 Jan 2007 09:34:51 -0500
Message-ID: <200701250934.51302.gene.heskett@verizon.net>
References: <1169707854.10593.41.camel@dv>
	<200701250905.33129.gene.heskett@verizon.net>
	<20070125152321.434bb17c@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ivo Van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-reply-to: <20070125152321.434bb17c-IhiK2ZEFs2oCVLCxKZUutA@public.gmane.org>
Content-disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 25 January 2007 09:23, Jiri Benc wrote:
>On Thu, 25 Jan 2007 09:05:32 -0500, Gene Heskett wrote:
>> Oh?  I'm sitting here watching the tty0 screen of my lappy after x has
>> been started, and I have established a connection, but SoftMAC is
>> still logging its scan activity, starting with channel 1 and scanning
>> 14 channels.  Its doing this at approximately 2 minute intervals.  So
>> I think we have your definition of a clear bug and misbehaviour.
>
>Yes. As well as some other wireless drivers. But that's not worth
>fixing.
>
>Also, please note that softmac isn't going to do user space MLME so
>it is not relevant at all.

MLME?  More acronyms I've not put in my wet dictionary.. :)

> Jiri

-- 
Cheers, Gene
"There are four boxes to be used in defense of liberty:
 soap, ballot, jury, and ammo. Please use in that order."
-Ed Howdershelt (Author)
Yahoo.com and AOL/TW attorneys please note, additions to the above
message by Gene Heskett are:
Copyright 2007 by Maurice Eugene Heskett, all rights reserved.
