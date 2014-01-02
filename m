From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/2] mlx4_en: Add PTP support
Date: Thu, 02 Jan 2014 03:32:11 -0500 (EST)
Message-ID: <20140102.033211.1823635212851916910.davem@davemloft.net>
References: <1388511580-3657-1-git-send-email-shawn.bohrer@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, amirv@mellanox.com,
	richardcochran@gmail.com, netdev@vger.kernel.org,
	tomk@rgmadvisors.com, hadarh@mellanox.com, sbohrer@rgmadvisors.com
To: shawn.bohrer@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbaABIcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 03:32:13 -0500
In-Reply-To: <1388511580-3657-1-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Bohrer <shawn.bohrer@gmail.com>
Date: Tue, 31 Dec 2013 11:39:38 -0600

> This adds support to the mlx4_en driver to support running a PTP client
> with hardware timestamp support.  It also allows synchronization of the
> hardware timestamped packets with the system clock.

Both patches applied.
