From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 0/2] Small fixes for sky2 Yukon-2 Optima chip
Date: Wed, 9 Dec 2009 11:35:22 -0800
Message-ID: <20091209113522.303d0cb5@nehalam>
References: <1259853122-21134-1-git-send-email-tiwai@suse.de>
	<20091203.160719.140476237.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tiwai@suse.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51056 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756975AbZLITfW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2009 14:35:22 -0500
In-Reply-To: <20091203.160719.140476237.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 Dec 2009 16:07:19 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Takashi Iwai <tiwai@suse.de>
> Date: Thu,  3 Dec 2009 16:12:00 +0100
> 
> > here are two small patches to fix the bugs found on sky2 Yukon-2
> > Optima chip.  These are for the latest net-next kernel.  Would be
> > nice if they come in for 2.6.33.
> 
> Please always CC: the driver maintainer when submitting changes
> to a driver.
> 
> Stephen, please have a look at these, thanks.

Apply them, if anything comes up the fix can go on top of these

-- 
