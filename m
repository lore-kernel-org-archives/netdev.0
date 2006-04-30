From: Jiri Benc <jbenc@suse.cz>
Subject: Re: wireless-dev: warnings while removing bcm43xx-d80211
Date: Sun, 30 Apr 2006 21:18:04 +0200
Message-ID: <20060430211804.14751754@logostar.upir.cz>
References: <1146308425.5019.38.camel@localhost>
	<20060430141520.5f0ef66a@logostar.upir.cz>
	<200604301449.46431.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Broadcom Linux <bcm43xx-dev@berlios.de>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from r2u241.chello.upc.cz ([62.245.84.241]:32688 "EHLO
	localhost.localdomain") by vger.kernel.org with ESMTP
	id S1750981AbWD3TSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Apr 2006 15:18:11 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200604301449.46431.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sun, 30 Apr 2006 14:49:45 +0200, Michael Buesch pise:
> Hm, seems like I did not listen to you. :P
> How does this happen? I never saw it.

Usually when a net interface is renamed (by udev for example). The stack
then tries to remove wrong procfs directory.

 Jiri

-- 
Jiri Benc
SUSE Labs
