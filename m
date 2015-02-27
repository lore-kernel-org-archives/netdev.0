From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] team: allow TSO being set on master
Date: Fri, 27 Feb 2015 17:11:41 -0500 (EST)
Message-ID: <20150227.171141.1491925871847983198.davem@davemloft.net>
References: <1424890331-6850-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jprochaz@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54633 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755492AbbB0WLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 17:11:44 -0500
In-Reply-To: <1424890331-6850-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 25 Feb 2015 19:52:11 +0100

> This patch allows TSO being set/unset on the master, so that GSO
> segmentation is done after team layer.
> 
> Similar patch is present for bonding:
> 	b0ce3508b25e ("bonding: allow TSO being set on bonding master")
> and bridge:
> 	f902e8812ef6 ("bridge: Add ability to enable TSO")
> 
> Suggested-by: Jiri Prochazka <jprochaz@redhat.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks Jiri.
