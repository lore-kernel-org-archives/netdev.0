From: David Miller <davem@davemloft.net>
Subject: Re: [stable] [PATCH] be2net: Bug fix to support newer generation
 of BE ASIC
Date: Thu, 28 Jan 2010 23:05:20 -0800 (PST)
Message-ID: <20100128.230520.183040907.davem@davemloft.net>
References: <20100129055157.GA10427@serverengines.com>
	<20100128.215629.189699027.davem@davemloft.net>
	<20100129064747.GA11514@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ajitkhaparde@gmail.com, ben@decadent.org.uk, greg@kroah.com,
	netdev@vger.kernel.org, stable-review@kernel.org, stable@kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48781
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755275Ab0A2HFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 02:05:08 -0500
In-Reply-To: <20100129064747.GA11514@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Fri, 29 Jan 2010 12:17:49 +0530

> On 28/01/10 21:56 -0800, David Miller wrote:
>> From: Ajit Khaparde <ajitkhaparde@gmail.com>
>> Date: Fri, 29 Jan 2010 11:21:59 +0530
>> 
>> > I plan rectify the error pointed by Ben and Greg and spin the patch again and
>> > resend it.  Please let me know if you think otherwise.
>> 
>> I already made the obvious memset() arg fix in my tree
>> as I said I would in my reply to Ben's posting.
> I never saw this mail. Probably its lost for good.
> It did not even show up on
> http://patchwork.ozlabs.org/patch/43852

Ugh, it was stuck in my email client waiting for me to hit
'send', which I just did :-)
