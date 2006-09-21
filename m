From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 1/7] d80211:  add SIOCSIWTXPOW, SIOCGIWTXPOW,
 SIOCSIWPOWER and SIOCGIWPOWER
Date: Thu, 21 Sep 2006 20:33:47 +0200
Message-ID: <20060921203347.44d66563@logostar.upir.cz>
References: <44F355DE.3000206@linux.intel.com>
	<20060921183040.12d679f2@logostar.upir.cz>
	<4512C133.7010509@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:18095 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751402AbWIUSdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 14:33:51 -0400
To: mabbas <mabbas@linux.intel.com>
In-Reply-To: <4512C133.7010509@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, 21 Sep 2006 09:43:31 -0700, mabbas pise:
> What about adding a new callback function fot txpower. 
> ieee80211_hw_config callback still confusing if txpower was
> changed for channel change or because the user setting txpower limit.

Why should the driver care?

 Jiri

-- 
Jiri Benc
SUSE Labs
