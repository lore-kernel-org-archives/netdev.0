From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] mpls: Allow mpls_gso to be built as module
Date: Fri, 31 Oct 2014 15:48:00 -0400 (EDT)
Message-ID: <20141031.154800.886861295179827674.davem@davemloft.net>
References: <1414655404-1572-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42963 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755603AbaJaTsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 15:48:02 -0400
In-Reply-To: <1414655404-1572-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 30 Oct 2014 00:50:04 -0700

> Kconfig already allows mpls to be built as module. Following patch
> fixes Makefile to do same.
> 
> CC: Simon Horman <simon.horman@netronome.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied.
