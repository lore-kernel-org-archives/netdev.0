From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 10/24] RT2x00: Add software and hardware sequence
 counting
Date: Wed, 26 Jul 2006 19:56:57 +0200
Message-ID: <20060726195657.058ab234@griffin.suse.cz>
References: <200607261905.08494.IvDoorn@gmail.com>
	<20060726193337.27923ef1@griffin.suse.cz>
	<200607261948.35770.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:63109 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751094AbWGZR5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 13:57:00 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200607261948.35770.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 26 Jul 2006 19:48:35 +0200, Ivo van Doorn wrote:
> To be the honest the same reason as why I didn't yell about RTS,

Yes, another thing that should be in the stack.

> I had placed it on my todo list for d80211. ;)

Please, if you encounter such thing, speak loudly so everybody
interested has an idea what's missing.

Could you send me your d80211 todo list?

> But due to limited time I have never started on it, and I still had to look to 
> see if it belongs in d80211 or in the driver. Very often the device itself is 
> handling the sequence counting. rt2400pci and rt2500pci just seem to be the
> exception.

It belongs to the stack. Both from theoretical (it is a part of 802.11
spec) and practical (at least two drivers need that) point of view.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
