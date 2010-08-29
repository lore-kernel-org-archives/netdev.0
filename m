From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: 2.6.34.1 page allocation failure
Date: Sun, 29 Aug 2010 17:37:14 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1008291736170.8562@uplift.swm.pp.se>
References: <4C70BFF3.8030507@hardwarefreak.com> <alpine.DEB.1.10.1008220842400.8562@uplift.swm.pp.se> <AANLkTin48SJ58HvFqjrOnQBMqLcbECtqXokweV00dNgv@mail.gmail.com> <alpine.DEB.2.00.1008221734410.21916@router.home> <4C724141.8060000@kernel.org>
 <4C72F7C6.3020109@hardwarefreak.com> <4C74097A.5020504@kernel.org> <alpine.DEB.1.10.1008242114120.8562@uplift.swm.pp.se> <4C7A3B1D.7050500@kernel.org> <alpine.DEB.1.10.1008291433420.8562@uplift.swm.pp.se> <4C7A5DDE.8030106@kernel.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stan Hoeppner <stan@hardwarefreak.com>,
	Christoph Lameter <cl@linux.com>,
	Linux Kernel List <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pekka Enberg <penberg@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:58314 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753539Ab0H2PhP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Aug 2010 11:37:15 -0400
In-Reply-To: <4C7A5DDE.8030106@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 29 Aug 2010, Pekka Enberg wrote:

> There aren't any debug options that need to be enabled. The reason I'm 
> asking is because we had a bunch of similar issues being reported 
> earlier that got fixed and it's been calm for a while. That's why it 
> would be interesting to know if 2.6.35 or 2.6.36-rc2 (if it's not too 
> unstable to test) fixes things.

Oki, I have installed 2.6.35 now (found backport from ubuntu 10.10 for 
10.04), just need to do a reboot at some convenient time.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
