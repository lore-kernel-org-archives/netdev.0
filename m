From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: Add process name and pid to deprecation warnings
Date: Fri, 03 Jan 2014 19:37:17 -0500 (EST)
Message-ID: <20140103.193717.760371809302807301.davem@davemloft.net>
References: <1388685267-18319-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, vyasevich@gmail.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35397 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754097AbaADAhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 19:37:19 -0500
In-Reply-To: <1388685267-18319-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu,  2 Jan 2014 12:54:27 -0500

> Recently I updated the sctp socket option deprecation warnings to be both a bit
> more clear and ratelimited to prevent user processes from spamming the log file.
> Ben Hutchings suggested that I add the process name and pid to these warnings so
> that users can tell who is responsible for using the deprecated apis.  This
> patch accomplishes that.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

This is a net positive improvement, so I'm applying this.

Thanks Neil.
