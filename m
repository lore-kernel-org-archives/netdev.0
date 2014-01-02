From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netlink: cleanup rntl_af_register
Date: Wed, 01 Jan 2014 23:44:18 -0500 (EST)
Message-ID: <20140101.234418.1201395749444285240.davem@davemloft.net>
References: <20131230104132.13a10e3d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46466 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203AbaABEoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 23:44:20 -0500
In-Reply-To: <20131230104132.13a10e3d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 30 Dec 2013 10:41:32 -0800

> The function __rtnl_af_register is never called outside this
> code, and the return value is always 0.

Applied.
