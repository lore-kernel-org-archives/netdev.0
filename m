From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Remove rx_copybreak module param, use
 ethtool to change its value
Date: Tue, 16 Sep 2014 16:57:08 -0400 (EDT)
Message-ID: <20140916.165708.1449540419013471862.davem@davemloft.net>
References: <1410900687-9686-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dave@thedillows.org, pcnet32@frontier.com,
	romieu@fr.zoreil.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754455AbaIPU5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 16:57:09 -0400
In-Reply-To: <1410900687-9686-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Wed, 17 Sep 2014 02:21:24 +0530

> This series removes the rx_copybreak module param and adds ethtool support for
> the same.

Module parameters are an interface visible to the user and cannot just
be removed.

Sorry.
