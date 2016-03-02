From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4: remove left over dead code
Date: Wed, 02 Mar 2016 15:02:53 -0500 (EST)
Message-ID: <20160302.150253.1180530769100101519.davem@davemloft.net>
References: <1456763886-993-1-git-send-email-eric.engestrom@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.engestrom@imgtec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58138 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754220AbcCBUDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 15:03:00 -0500
In-Reply-To: <1456763886-993-1-git-send-email-eric.engestrom@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Engestrom <eric.engestrom@imgtec.com>
Date: Mon, 29 Feb 2016 16:38:06 +0000

> 8cc785f6f429c2a3fb81745dc142cbd72a462c4a ("net: ipv4: make the ping
> /proc code AF-independent") removed the code using it, but renamed this
> variable instead of removing it.
> 
> Signed-off-by: Eric Engestrom <eric.engestrom@imgtec.com>

Applied.
