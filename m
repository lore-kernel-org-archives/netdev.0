From: David Miller <davem@davemloft.net>
Subject: Re: Fixed PHY regression
Date: Mon, 08 Oct 2007 14:20:57 -0700 (PDT)
Message-ID: <20071008.142057.31775797.davem@davemloft.net>
References: <008601c809d7$7f5dc710$04ac10ac@Jocke>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: joakim.tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33087
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751736AbXJHVVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 17:21:12 -0400
In-Reply-To: <008601c809d7$7f5dc710$04ac10ac@Jocke>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Date: Mon, 8 Oct 2007 20:17:33 +0200

> 
> David, any chance the second item, Oops while modprobing phy fixed module, in
> http://marc.info/?l=linux-kernel&m=119178673421891&w=2
> will make it into 2.6.23? 
> 
> The fix is now in your tree,
> http://git.kernel.org/?p=linux/kernel/git/davem/bak-net-2.6.24.git;a=commit;h=bbb4c0c35a4c2aed5e025b668c8dfc99c5b74cff
> 
> It has been in Andrews tree for a while, then in Garzik and now it is in your tree.

Jeff, any reason you didn't submit this one for 2.6.23?
