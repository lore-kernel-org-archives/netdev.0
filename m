From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ipv6: call iptunnel_xmit with NULL sock
 pointer if no tunnel sock is available
Date: Wed, 08 Apr 2015 12:10:02 -0400 (EDT)
Message-ID: <20150408.121002.995357124373064974.davem@davemloft.net>
References: <46878d19779a655995b36701de854cb23a3bf4b5.1428505261.git.hannes@stressinduktion.org>
	<46878d19779a655995b36701de854cb23a3bf4b5.1428505261.git.hannes@stressinduktion.org>
	<8994d7096bfee43cc0313b1776478536f785793e.1428505261.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38986 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932110AbbDHQKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 12:10:04 -0400
In-Reply-To: <8994d7096bfee43cc0313b1776478536f785793e.1428505261.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed,  8 Apr 2015 17:01:23 +0200

> Fixes: 79b16aadea32cce ("udp_tunnel: Pass UDP socket down through udp_tunnel{, 6}_xmit_skb().")
> Reported-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
