From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 8/10] d80211: get rid of default management interface
Date: Fri, 21 Apr 2006 23:03:18 +0200
Message-ID: <20060421230318.1e361589@griffin.suse.cz>
References: <20060421205328.39BE2482C1@silver.suse.cz>
	<1145653198.3897.47.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:33448 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964775AbWDUVDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 17:03:20 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1145653198.3897.47.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Apr 2006 22:59:58 +0200, Johannes Berg wrote:
> What's the management interface used for? In some small discussion
> didn't we say that we'd rather move to having one netlink socket for
> this?

Yes, it's just a temporary solution.

> Maybe then we can get away with not having native 802.11 devices which
> seem to somewhat scare people...

We'll see :-) It's not so important now.

-- 
Jiri Benc
SUSE Labs
