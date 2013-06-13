From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Thu, 13 Jun 2013 08:47:51 +0200
Message-ID: <20130613064751.GA30629@electric-eye.fr.zoreil.com>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
 <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
 <20130612230257.GB21234@electric-eye.fr.zoreil.com>
 <1371095162.31941.1.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org,
	mcgrof@do-not-panic.com, kvalo@adurom.com, adrian.chadd@gmail.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47173 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932374Ab3FMGsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 02:48:04 -0400
Content-Disposition: inline
In-Reply-To: <1371095162.31941.1.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> :
> On Thu, 2013-06-13 at 01:02 +0200, Francois Romieu wrote:
[...]
> > 	return err ? err : __alx_read_phy_reg(hw, ALX_MII_DBG_DATA, pdata);
> 
> I think that's far poorer style.

Nevermind. The change is bogus.

-- 
Ueimor
