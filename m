From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Rename lookup_neigh_params function
Date: Mon, 13 Jul 2009 11:17:59 -0700 (PDT)
Message-ID: <20090713.111759.86196488.davem@davemloft.net>
References: <1247475220-20518-1-git-send-email-klto@zhaw.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: klto@zhaw.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36721
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756803AbZGMSRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2009 14:17:55 -0400
In-Reply-To: <1247475220-20518-1-git-send-email-klto@zhaw.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <klto@zhaw.ch>
Date: Mon, 13 Jul 2009 10:53:40 +0200

> Rename lookup_neigh_params to lookup_neigh_parms as the struct is named
> neigh_parms and all other functions dealing with the struct carry
> neigh_parms in their names.
> 
> Signed-off-by: Tobias Klauser <klto@zhaw.ch>

Applied, thanks.
