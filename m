From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] team: add support for non-ethernet devices
Date: Mon, 20 Aug 2012 02:42:12 -0700 (PDT)
Message-ID: <20120820.024212.561887543494934442.davem@davemloft.net>
References: <1345212048-1378-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752753Ab2HTJmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 05:42:13 -0400
In-Reply-To: <1345212048-1378-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 17 Aug 2012 16:00:48 +0200

> This is resolved by two things:
> 1) allow dev_addr of different length than ETH_ALEN
> 2) during port add, check for dev->type and change it if necessary
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Looks good, applied, thanks Jiri.
