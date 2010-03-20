From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] netlink: fix unaligned access in nla_get_be64()
Date: Fri, 19 Mar 2010 22:44:26 -0700 (PDT)
Message-ID: <20100319.224426.28795747.davem@davemloft.net>
References: <20100316232247.4185.19426.stgit@decadence>
	<20100316233044.4185.69099.stgit@decadence>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39180
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751263Ab0CTFoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 01:44:03 -0400
In-Reply-To: <20100316233044.4185.69099.stgit@decadence>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Wed, 17 Mar 2010 00:30:44 +0100

> This patch fixes a unaligned access in nla_get_be64() that was
> introduced by myself in a17c859849402315613a0015ac8fbf101acf0cc1.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied.
