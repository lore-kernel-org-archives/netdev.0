From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCHv3 0/9] macb: add support for Cadence GEM
Date: Tue, 9 Aug 2011 16:59:40 +0200
Message-ID: <20110809145940.GP22213@game.jcrosoft.org>
References: <1312881411-2376-1-git-send-email-jamie@jamieiles.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 14.mo3.mail-out.ovh.net ([188.165.43.98]:32804 "EHLO
	mo3.mail-out.ovh.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752760Ab1HIPSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 11:18:17 -0400
Received: from mail191.ha.ovh.net (b9.ovh.net [213.186.33.59])
	by mo3.mail-out.ovh.net (Postfix) with SMTP id 9D67210045EC
	for <netdev@vger.kernel.org>; Tue,  9 Aug 2011 17:18:25 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1312881411-2376-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10:16 Tue 09 Aug     , Jamie Iles wrote:
> This is largely a repost of the series I posted back in March.  The only changes
> since then are rebasing onto 3.1-rc1 and changing the gem conditionals from a
> boolean in the macb structure to an inline helper as requested by
> Jean-Christophe.
> 
> This has been run-tested on picoxcell and compile tested for all AT91 platforms
> but I couldn't get a working cross compiler for avr32.
> 
> All patches are available in a git branch at
> 
> 	git://github.com/jamieiles/linux-2.6-ji.git macb-gem
> 
looks good except few comments

I'll test it later this week

Best Regards,
J.
