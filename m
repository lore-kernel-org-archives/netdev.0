From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: if_arp: add ARPHRD_RAWIP type
Date: Thu, 31 Oct 2013 00:27:26 -0400 (EDT)
Message-ID: <20131031.002726.309261257307917162.davem@davemloft.net>
References: <1383124271-15290-2-git-send-email-jukka.rissanen@linux.intel.com>
	<20131030.172556.454916501978452298.davem@davemloft.net>
	<C93A6A6E-D5BF-4008-8B4B-496A551DF70F@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jukka.rissanen@linux.intel.com, netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36689 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712Ab3JaE11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 00:27:27 -0400
In-Reply-To: <C93A6A6E-D5BF-4008-8B4B-496A551DF70F@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Wed, 30 Oct 2013 23:26:37 +0100

> Posting them on netdev is mainly for checking that the changes we
> have to make outside the Bluetooth subsystem are in sync.

Changes without use context and examples cannot be reviewed.

You have to provide those example users here, not on some external
list for us to look at.
