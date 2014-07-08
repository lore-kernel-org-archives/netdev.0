From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] bonding: remove no longer relevant vlan
 warnings
Date: Mon, 07 Jul 2014 21:32:19 -0700 (PDT)
Message-ID: <20140707.213219.1034908728845983391.davem@davemloft.net>
References: <1404294938-9968-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net, teg@jklm.no, jay.vosburgh@canonical.com,
	mkubecek@suse.cz
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbaGHEcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 00:32:20 -0400
In-Reply-To: <1404294938-9968-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed,  2 Jul 2014 11:55:38 +0200

> These warnings are no longer relevant. Even when last slave is
> removed, there is a valid address assigned to bond (random).
> The correct functionality of vlans is ensured by maintaining unicast
> list in vlan_sync_address().
> 
> Suggested-by: Jay Vosburgh <jay.vosburgh@canonical.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks.
