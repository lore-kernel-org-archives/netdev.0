From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: Re: [PATCH v2 0/4] net/macb: add sama5d2 support
Date: Thu, 18 Jun 2015 17:34:19 +0200
Message-ID: <20150618153419.GL27492@piout.net>
References: <cover.1434637286.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1434637286.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/06/2015 at 16:27:19 +0200, Nicolas Ferre wrote :
> Hi,
> 
> This series is basically the support for another flavor of the GEM IP
> configuration. It ended up being a series because of some little fixes made to
> the binding documentation before adding the new compatibility string.
> 
> Bye,
> 
> v2: - fix bindings
>     - add sama5d2 compatibility string to the binding documentation
> 
> Cyrille Pitchen (1):
>   net/macb: add config for Atmel sama5d2 SoCs
> 
> Nicolas Ferre (3):
>   net/macb: bindings doc: fix compatibility string
>   net/macb: bindings doc/trivial: fix sama5d4 comment
>   net/macb: bindings doc: add sama5d2 compatibility sting
> 
>  Documentation/devicetree/bindings/net/macb.txt | 5 +++--
>  drivers/net/ethernet/cadence/macb.c            | 8 ++++++++
>  2 files changed, 11 insertions(+), 2 deletions(-)
> 

For the patch set:
Acked-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>

-- 
Alexandre Belloni, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
