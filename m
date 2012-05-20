From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4/ipconfig: neaten __setup placement
Date: Sun, 20 May 2012 04:07:11 -0400 (EDT)
Message-ID: <20120520.040711.1958974633833486664.davem@davemloft.net>
References: <1337472279-18615-1-git-send-email-eldad@fogrefinery.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eldad@fogrefinery.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55872 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698Ab2ETIJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 May 2012 04:09:59 -0400
In-Reply-To: <1337472279-18615-1-git-send-email-eldad@fogrefinery.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eldad Zack <eldad@fogrefinery.com>
Date: Sun, 20 May 2012 02:04:39 +0200

> The __setup macro should follow the corresponding setup handler.
> 
> Signed-off-by: Eldad Zack <eldad@fogrefinery.com>

Applied.
