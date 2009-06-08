From: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Subject: Re: [PATCH 3/7] initdev:kernel:Await console discovery, v6
Date: Tue, 09 Jun 2009 00:30:03 +0200
Message-ID: <4A2D90EB.4070005@s5r6.in-berlin.de>
References: <20090606023407.GA5695@cuplxvomd02.corp.sa.net> <4A2A2EED.3060506@s5r6.in-berlin.de> <20090608221344.GB22222@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090608221344.GB22222-CFZJ1or75eBPWxJt6d6B6bQa8qPdvLwY@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David VomLehn wrote:
> On Sat, Jun 06, 2009 at 04:55:09AM -0400, Stefan Richter wrote:
>> David VomLehn wrote:
...
>>> v3.2	Use only a single new command line parameter by adding the possible
>>> 	value "forever".  Add message specifying the parameter to modify to
>>> 	increase the delay for console initialization
>>> v3.1	Correct the abbreviation for milliseconds in
>>> 	Documentation/kernel-parameters.txt to be "ms", not "mS". Thanks to
...
>>> ---
>>>  drivers/accessibility/braille/braille_console.c |    2 +
>>>  kernel/printk.c                                 |   29 ++++++++++++++++++++++-
>>>  2 files changed, 30 insertions(+), 1 deletions(-)
>> Is this diff complete?
> 
> To the best of my knowledge, yes, it is complete. What makes it look as though
> it might not be?

The history notes.
kernel-parameters.txt, new command line parameter...
-- 
Stefan Richter
-=====-==--= -==- -=--=
http://arcgraph.de/sr/
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
