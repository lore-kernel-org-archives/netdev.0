From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: Save the correct mac addr for hw-loopback
 connections in the L2T
Date: Mon, 14 Apr 2014 16:48:02 -0400 (EDT)
Message-ID: <20140414.164802.1606457718071861574.davem@davemloft.net>
References: <20140414192243.13234.46587.stgit@build.ogc.int>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com
To: swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461AbaDNUsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 16:48:03 -0400
In-Reply-To: <20140414192243.13234.46587.stgit@build.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>
Date: Mon, 14 Apr 2014 14:22:43 -0500

> Hardware needs the local device mac address to support hw loopback for
> rdma loopback connections.
> 
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>

Applied.
