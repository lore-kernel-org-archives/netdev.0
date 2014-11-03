From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] uapi: add missing network related headers to kbuild
Date: Mon, 03 Nov 2014 12:33:47 -0500 (EST)
Message-ID: <20141103.123347.23265001622484562.davem@davemloft.net>
References: <20141102113141.7aa1065c@urahara>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47708 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948AbaKCRdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 12:33:49 -0500
In-Reply-To: <20141102113141.7aa1065c@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sun, 2 Nov 2014 11:31:41 -0800

> The makefile for sanitizing kernel headers uses the kbuild file
> to determine which files to do. Several networking related headers
> were missing. Without these headers iproute2 build would break.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks Stephen.
