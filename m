From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] geneve: use network byte order for destination port
 config parameter
Date: Mon, 21 Sep 2015 16:24:04 -0700 (PDT)
Message-ID: <20150921.162404.1245771010622997220.davem@davemloft.net>
References: <1442518065-23294-1-git-send-email-linville@tuxdriver.com>
	<1442606350-11170-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, eric.dumazet@gmail.com,
	jesse@nicira.com, stephen@networkplumber.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56375 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762AbbIUXYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 19:24:06 -0400
In-Reply-To: <1442606350-11170-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 18 Sep 2015 15:59:10 -0400

> This is primarily for consistancy with vxlan and other tunnels which
> use network byte order for similar parameters.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

This doesn't apply to any of my trees.  Can you respin it against
'net'?  Thanks.
