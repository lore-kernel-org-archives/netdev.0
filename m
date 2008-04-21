From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make struct ip6_prohibit_entry_template static
Date: Mon, 21 Apr 2008 02:30:26 -0700 (PDT)
Message-ID: <20080421.023026.50676407.davem@davemloft.net>
References: <20080421084841.GQ26897@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44332
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753392AbYDUJaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 05:30:24 -0400
In-Reply-To: <20080421084841.GQ26897@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Mon, 21 Apr 2008 11:48:41 +0300

> This patch makes the needlessly global struct 
> ip6_prohibit_entry_template static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Patch applied, thanks Adrian.
