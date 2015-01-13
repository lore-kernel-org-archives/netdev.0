From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/2] net: rename vlan_tx_* helpers since "tx"
 is misleading there
Date: Tue, 13 Jan 2015 17:51:27 -0500 (EST)
Message-ID: <20150113.175127.1647857659073721450.davem@davemloft.net>
References: <1421165624-19882-1-git-send-email-jiri@resnulli.us>
	<1421165624-19882-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, kaber@trash.net
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37027 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbbAMWva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 17:51:30 -0500
In-Reply-To: <1421165624-19882-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 13 Jan 2015 17:13:44 +0100

> The same macros are used for rx as well. So rename it.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied.
