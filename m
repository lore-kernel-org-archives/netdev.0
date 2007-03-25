From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make dccp_write_xmit_timer() static again
Date: Sat, 24 Mar 2007 21:01:43 -0700 (PDT)
Message-ID: <20070324.210143.97294360.davem@davemloft.net>
References: <20070324130652.GJ752@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, acme@mandriva.com, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56643
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932687AbXCYEBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2007 00:01:45 -0400
In-Reply-To: <20070324130652.GJ752@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sat, 24 Mar 2007 14:06:52 +0100

> dccp_write_xmit_timer() needlessly became global.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
