From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3/6] net: sh_eth: remove almost #ifdef of SH7763
Date: Mon, 14 Mar 2011 14:10:55 -0700 (PDT)
Message-ID: <20110314.141055.115922945.davem@davemloft.net>
References: <4D75E1EA.50006@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35162
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754351Ab1CNVKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 17:10:17 -0400
In-Reply-To: <4D75E1EA.50006@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Date: Tue, 08 Mar 2011 16:59:38 +0900

> The SH7763 has GETHER. So the specification of some registers differs than
> other CPUs. This patch removes almost #ifdef of CONFIG_CPU_SUBTYPE_SH7763.
> Then we are able to add other CPU's GETHER easily.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied.
