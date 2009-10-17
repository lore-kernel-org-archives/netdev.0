From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: RE: [PATCH NEXT 1/7] netxen; update version to 4.0.56
Date: Fri, 16 Oct 2009 18:15:16 -0700
Message-ID: <7608421F3572AB4292BB2532AE89D5658B0B88FAE9@AVEXMB1.qlogic.org>
References: <1255673353-31797-1-git-send-email-dhananjay@netxen.com>
	<1255673353-31797-2-git-send-email-dhananjay@netxen.com>
 <20091016.175621.76312736.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:11199 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986AbZJQBQH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 21:16:07 -0400
In-Reply-To: <20091016.175621.76312736.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alright, this was really marker for earlier patch series.

But I will re-spin to even higher rev, use it as marker everything upto this patch series.

Thanks,
Dhananjay

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Friday, October 16, 2009 5:56 PM
To: Dhananjay Phadke
Cc: netdev@vger.kernel.org
Subject: Re: [PATCH NEXT 1/7] netxen; update version to 4.0.56

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Thu, 15 Oct 2009 23:09:07 -0700

> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

This doesn't make any sense at all.

You should update the driver version _AFTER_ your set
of changes, not before.

I have never in my entire life seen someone bump the
driver version before the actual changes.

Please respin this properly, thanks.
