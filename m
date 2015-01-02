From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: Add Transparent Ethernet Bridging
 GRO support.
Date: Fri, 02 Jan 2015 15:46:56 -0500 (EST)
Message-ID: <20150102.154656.189568759364251911.davem@davemloft.net>
References: <1419995416-29987-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbbABUq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 15:46:59 -0500
In-Reply-To: <1419995416-29987-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Tue, 30 Dec 2014 19:10:15 -0800

> Currently the only tunnel protocol that supports GRO with encapsulated
> Ethernet is VXLAN. This pulls out the Ethernet code into a proper layer
> so that it can be used by other tunnel protocols such as GRE and Geneve.
> 
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied.
