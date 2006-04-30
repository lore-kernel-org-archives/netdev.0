From: Jiri Benc <jbenc@suse.cz>
Subject: Re: wireless-dev: warnings while removing bcm43xx-d80211
Date: Sun, 30 Apr 2006 14:15:20 +0200
Message-ID: <20060430141520.5f0ef66a@logostar.upir.cz>
References: <1146308425.5019.38.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Broadcom Linux <bcm43xx-dev@berlios.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from r2u241.chello.upc.cz ([62.245.84.241]:23984 "EHLO
	localhost.localdomain") by vger.kernel.org with ESMTP
	id S1750821AbWD3MPY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Apr 2006 08:15:24 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1146308425.5019.38.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sat, 29 Apr 2006 13:00:25 +0200, Johannes Berg pise:
> This didn't look too good to me, maybe someone can investigate?
> 
> [24070.841580] Badness in remove_proc_entry at fs/proc/generic.c:732
> [24070.841593] Call Trace:
> [...]

I know about this (also mentioned it at Wireless summit), I'm working on
it.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
