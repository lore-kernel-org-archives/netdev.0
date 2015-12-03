From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 00/28] bonding/team offload + mlxsw
 implementation
Date: Thu, 3 Dec 2015 09:21:02 +0100
Message-ID: <20151203082102.GB2331@nanopsycho.orion>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
 <20151202225353.GR2355@nanopsycho.orion>
 <20151202.183843.2187828582948432661.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35172 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757564AbbLCIVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 03:21:04 -0500
Received: by wmuu63 with SMTP id u63so10528492wmu.0
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 00:21:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20151202.183843.2187828582948432661.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Dec 03, 2015 at 12:38:43AM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Wed, 2 Dec 2015 23:53:53 +0100
>
>> Dave, why this was marked "Changes Requested" in patchwork?
>
>Because you gotta kill that BUG_ON() as per our discussion.

That is different patchset. I'm going to send bugon kill as a separate
patch.
