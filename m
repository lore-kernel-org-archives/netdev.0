From: Captain Obvious <romieu@fr.zoreil.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Mon, 1 Oct 2012 20:34:52 +0200
Message-ID: <20121001183452.GA4492@electric-eye.fr.zoreil.com>
References: <1348779826.5093.1750.camel@edumazet-glaptop> <1348780624.5093.1767.camel@edumazet-glaptop> <50656C4A.8090302@googlemail.com> <1348831592.5093.2251.camel@edumazet-glaptop> <5068648C.7050005@googlemail.com> <1349034330.12401.210.camel@edumazet-glaptop> <506955F3.8050304@googlemail.com> <1349082950.12401.669.camel@edumazet-glaptop> <5069B300.9080308@googlemail.com> <1349105498.12401.706.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gpiez@web.de
To: Chris Clayton <chris2553@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53229 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085Ab2JASyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 14:54:13 -0400
Content-Disposition: inline
In-Reply-To: <1349105498.12401.706.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> :
[...]
> > > Could you send
> > >
> > > iptables -t -nat -nvL
> > 
> > $ iptables -t -nat -nvL
                  ^ typo

Please try "iptables -t nat -nvL" as was also suggested.

-- 
Ueimor
