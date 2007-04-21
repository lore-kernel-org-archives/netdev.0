From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Uninline tcp_done
Date: Fri, 20 Apr 2007 17:11:58 -0700 (PDT)
Message-ID: <20070420.171158.22122706.davem@davemloft.net>
References: <200704051244.03511.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ak@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53868
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753520AbXDUALy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 20:11:54 -0400
In-Reply-To: <200704051244.03511.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Thu, 5 Apr 2007 12:44:03 +0200

> 
> The function is quite big and has several call sites and nothing
> to collapse by compiler optimization on inlining.
> 
> Besides it's nicer to read in a in .c file.
> 
> Signed-off-by: Andi Kleen <ak@suse.de>

Applied, thanks Andi.
