From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH] platform: Facilitate the creation of pseduo-platform busses
Date: Thu, 05 Aug 2010 15:24:31 -0700
Message-ID: <87eiecr940.fsf@deeprootsystems.com>
References: <4C59E654.1090403@codeaurora.org>
	<877hk56hiy.fsf@deeprootsystems.com> <4C5A0C68.9080500@codeaurora.org>
	<87fwytxdba.fsf@deeprootsystems.com> <4C5AE75F.5020507@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-msm\@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"linux-omap\@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"damm\@opensource.se" <damm@opensource.se>,
	"lethal\@linux-sh.org" <lethal@linux-sh.org>,
	"rjw\@sisk.pl" <rjw@sisk.pl>,
	"eric.y.miao\@gmail.com" <eric.y.miao@gmail.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>, alan@lxorguk.ukuu.org.uk,
	zt.tmzt@gmail.com, grant.likely@secretlab.ca, magnus.damm@gmail.com
To: Patrick Pannuto <ppannuto@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:54336 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760882Ab0HEWYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 18:24:35 -0400
In-Reply-To: <4C5AE75F.5020507@codeaurora.org> (Patrick Pannuto's message of
	"Thu, 05 Aug 2010 09:31:27 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick Pannuto <ppannuto@codeaurora.org> writes:

>> 
>>> You had indicated that you were going on vacation for a month and I
>>> had not seen any more follow-up on this issue, so I forged ahead.
>> 
>> Great, I'm glad you forged ahead.  There is definitely a broader need
>> for something like this, and I have no personal attachment to the code.
>> 
>> I have no problems with you continuing the work (in fact, I'd prefer it.
>> I have lots of other things to catch up on after my vacation.)
>> 
>> In the future though, it's common (and kind) to note the original author
>> in the changelog when basing a patch on previous work.  Something like
>> "originally written by..."  or "based on the work of..." etc.
>
> Ok, I can do that; that was the intention of the "original inspiration from"
> line at the beginning.  

Maybe we need an 'Inspired-by:'  tag. :)

> Is there a more formal way of indicating this in the
> next version of the patch? Should I add you as a "From:" or an "Author:"?

I don't know if there is an official way of doing this.

I typically add something like "based on the idea/code originally
proposed/written by John Doe" in the changelog, and then add Cc: John
Doe <...> in the changelog too, but AFAIK, none of this is formalized.

Kevin
