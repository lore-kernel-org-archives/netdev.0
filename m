From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: make local functions static
Date: Sun, 29 Dec 2013 16:38:44 -0500 (EST)
Message-ID: <20131229.163844.871718415804284101.davem@davemloft.net>
References: <20131229113951.6ef99f27@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634Ab3L2Viq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 16:38:46 -0500
In-Reply-To: <20131229113951.6ef99f27@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sun, 29 Dec 2013 11:39:51 -0800

> The following are only used in one file:
>   tcp_connect_init
>   tcp_set_rto
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
