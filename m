From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Subject: RE: Fixed PHY regression
Date: Tue, 9 Oct 2007 07:46:59 +0200
Message-ID: <00ab01c80a37$cfb19560$04ac10ac@Jocke>
References: <470AC3B2.7090802@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "'Jeff Garzik'" <jeff@garzik.org>,
	"'David Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:25020 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750806AbXJIFrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 01:47:04 -0400
In-Reply-To: <470AC3B2.7090802@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: Jeff Garzik [mailto:jeff@garzik.org] 
> Sent: den 9 oktober 2007 01:57
> To: David Miller
> Cc: joakim.tjernlund@transmode.se; netdev@vger.kernel.org
> Subject: Re: Fixed PHY regression
> 
> David Miller wrote:
> > From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
> > Date: Mon, 8 Oct 2007 20:17:33 +0200
> > 
> >> David, any chance the second item, Oops while modprobing 
> phy fixed module, in
> >> http://marc.info/?l=linux-kernel&m=119178673421891&w=2
> >> will make it into 2.6.23? 
> >>
> >> The fix is now in your tree,
> >> 
> http://git.kernel.org/?p=linux/kernel/git/davem/bak-net-2.6.24
.git;a=commit;h=bbb4c0c35a4c2aed5e025b668c8dfc99c5b74cff
> >>
> >> It has been in Andrews tree for a while, then in Garzik 
> and now it is in your tree.
> > 
> > Jeff, any reason you didn't submit this one for 2.6.23?
> 
> Two reasons:
> * despite the subject, after discussion it looked like a problem with 
> module release, making "build it into your kernel" a valid workaround

I don't use modules and this does not work for me. Basically
Fixed PHY is broken for me.

 Jocke

> * the fix was quite invasive this late in the game
> 
> If people still think it should go for 2.6.23, that's cool with me.
> 
> 	Jeff
> 
> 
> 
> 
> 

