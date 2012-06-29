From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] netxen_nic: restrict force firmware dump
 when dump is disabled.
Date: Fri, 29 Jun 2012 00:54:10 -0700 (PDT)
Message-ID: <20120629.005410.44755982936277224.davem@davemloft.net>
References: <1340950341-27252-1-git-send-email-rajesh.borundia@qlogic.com>
	<1340950341-27252-2-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	manish.chopra@qlogic.com
To: rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752861Ab2F2HyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 03:54:11 -0400
In-Reply-To: <1340950341-27252-2-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Date: Fri, 29 Jun 2012 02:12:21 -0400

> From: Manish chopra <manish.chopra@qlogic.com>
> 
> o Set the ethtool_dump flag (=ETH_FW_DUMP_DISABLE) when dump is disabled.
> o update driver version to 4.0.80
> 
> Signed-off-by: Manish chopra <manish.chopra@qlogic.com>
> Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>

Applied.
