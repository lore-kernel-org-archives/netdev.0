From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [BUG?] tcp: potential bug in tcp_is_sackblock_valid()
Date: Sun, 18 Sep 2011 23:20:40 +0200
Message-ID: <20110918212039.GD3033@nuttenaction>
References: <4E696FD0.7060702@intel.com>
 <20110909015429.GA9156@gondor.apana.org.au>
 <4E6975B2.8000603@intel.com>
 <alpine.DEB.2.00.1109091050550.11963@melkinpaasi.cs.helsinki.fi>
 <CAA93jw7L9KyXVevZ8dqE+ExLYP9=CLMmj1gPD88ihBuC6ZovOQ@mail.gmail.com>
 <1316378349.31335.34.camel@edumazet-laptop>
 <CAA93jw4sQJ63t6tH=SfUPahgprk1Yz4-E3yoMc6yvw=NeN1YBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	"Yan, Zheng" <zheng.z.yan@intel.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:41075 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932564Ab1IRVUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2011 17:20:42 -0400
Content-Disposition: inline
In-Reply-To: <CAA93jw4sQJ63t6tH=SfUPahgprk1Yz4-E3yoMc6yvw=NeN1YBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Dave Taht | 2011-09-18 14:04:44 [-0700]:

>A very large suite of network test tools runs on the router itself -
>netperf, nuttcp, iperf, httping, etc.

But then the router _act_ as an end-host - no forwarding.

HGN
