From: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Subject: Re: [ANNOUNCE] new iptables module match large amount of ip addresses
Date: Fri, 18 Sep 2009 01:46:45 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0909180142130.27543@artax.karlin.mff.cuni.cz>
References: <Pine.LNX.4.64.0909172100220.27299@artax.karlin.mff.cuni.cz>
 <alpine.LSU.2.00.0909180046410.20781@obet.zrqbmnf.qr>
 <Pine.LNX.4.64.0909180054410.21427@artax.karlin.mff.cuni.cz>
 <alpine.LSU.2.00.0909180130110.20781@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0909180130110.20781@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >I was saying how OpenBSD is better than Linux because OpenBSD has 
> >tree-based firewall tables --- hmm --- well --- Linux has them too, except 
> >that noone can really find them because they are not in the kernel.
> 
> You can build trees of chains with iptables. (Which would be quite a 
> fast thing if you do not have modules at hand.)

I thought about this too but I realized that building the tree in kernel 
would be easier to write than building it with a shell script :)

Mikulas
