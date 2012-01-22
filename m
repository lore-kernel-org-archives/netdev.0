From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] skge: add byte queue limit support
Date: Sun, 22 Jan 2012 14:24:36 -0500 (EST)
Message-ID: <20120122.142436.1814863629068968087.davem@davemloft.net>
References: <20120119164354.78ea63d6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752401Ab2AVTYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 14:24:38 -0500
In-Reply-To: <20120119164354.78ea63d6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 19 Jan 2012 16:43:54 -0800

> This also changes the cleanup logic slightly to aggregate
> completed notifications for multiple packets.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
