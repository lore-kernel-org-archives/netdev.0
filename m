From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] ip_tunnel fixes
Date: Tue, 16 Dec 2014 15:22:10 -0500 (EST)
Message-ID: <20141216.152210.575294449360908086.davem@davemloft.net>
References: <cover.1418759998.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbaLPUWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 15:22:12 -0500
In-Reply-To: <cover.1418759998.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 16 Dec 2014 21:05:19 +0100

> Thomas Graf (2):
>   ip_tunnel: Add sanity checks to ip_tunnel_encap_add_ops()
>   ip_tunnel: Add missing validation of encap type to
>     ip_tunnel_encap_setup()

Both applied, thanks Thomas.
