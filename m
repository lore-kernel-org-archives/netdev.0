From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 00/28] bonding/team offload + mlxsw
 implementation
Date: Wed, 02 Dec 2015 18:38:43 -0500 (EST)
Message-ID: <20151202.183843.2187828582948432661.davem@davemloft.net>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
	<20151202225353.GR2355@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52724 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757478AbbLBXio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 18:38:44 -0500
In-Reply-To: <20151202225353.GR2355@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 2 Dec 2015 23:53:53 +0100

> Dave, why this was marked "Changes Requested" in patchwork?

Because you gotta kill that BUG_ON() as per our discussion.
