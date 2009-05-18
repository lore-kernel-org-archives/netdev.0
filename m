From: Vladimir Ivashchenko <hazard@francoudi.com>
Subject: Re: HTB accuracy for high speed
Date: Tue, 19 May 2009 02:27:47 +0300
Message-ID: <1242689267.11814.1.camel@hazard2.francoudi.com>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com>
	 <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com>
	 <20090516141430.GB3013@ami.dom.local>
	 <298f5c050905180736m303f0c79ha30d3f791222fa1b@mail.gmail.com>
	 <1242688479.9558.60.camel@hazard2.francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz, Antonio Almeida <vexwek@gmail.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.thunderworx.net ([217.27.32.18]:3833 "EHLO
	cerber.thunderworx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241AbZERX16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 19:27:58 -0400
In-Reply-To: <1242688479.9558.60.camel@hazard2.francoudi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> With bond + HFSC + sfq, I'm able to reach the speed. It doesn't seem to
> overspill with 580 mbps load. Jarek, would your patches help with HSFC
> overspill ? I will check tomorrow under 750 mbps load. 

Please disregard my comment about HFSC. It still overspills heavily.

On a 400 mbps limit, I'm getting 520 mbps actual throughput.

-- 
Best Regards,
Vladimir Ivashchenko
Chief Technology Officer
PrimeTel PLC, Cyprus - www.prime-tel.com
Tel: +357 25 100100 Fax: +357 2210 2211


