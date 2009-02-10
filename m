From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] enic: bug fix: tx_timeout reset path
 fix-ups
Date: Mon, 09 Feb 2009 23:26:45 -0800 (PST)
Message-ID: <20090209.232645.238768771.davem@davemloft.net>
References: <20090210005505.24315.66810.stgit@palito_client100.nuovasystems.com>
	<20090210005722.24315.90194.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: scofeldm@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54070
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751592AbZBJH0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 02:26:51 -0500
In-Reply-To: <20090210005722.24315.90194.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>
Date: Mon, 09 Feb 2009 16:57:22 -0800

> enic: bug fix: tx_timeout reset path fix-ups
> 
> tx_timeout reset path needs to re-init dev and re-apply nic cfg to enable vlan stripping.
> 
> Signed-off-by: Scott Feldman <scofeldm@cisco.com>

Applied.
