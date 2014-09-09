From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH 1/5] net: mvberlin_eth: add an Ethernet driver for
 Marvell Berlin
Date: Tue, 9 Sep 2014 16:51:03 +0200
Message-ID: <20140909145103.GA15973@kwain>
References: <1409320263-10295-1-git-send-email-antoine.tenart@free-electrons.com>
 <1409320263-10295-2-git-send-email-antoine.tenart@free-electrons.com>
 <20140829145145.GA7735@arch.cereza>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	sebastian.hesselbarth@gmail.com,
	thomas.petazzoni@free-electrons.com,
	alexandre.belloni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140829145145.GA7735@arch.cereza>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ezequiel,

On Fri, Aug 29, 2014 at 11:51:45AM -0300, Ezequiel Garcia wrote:
> Hi Antoine,
>=20
> A quick look...

Well, it seems Sebastian is right and we can use the existing PXA168
Ethernet driver, so I just sent a new series doing that...

Thanks for the review anyway!

Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
