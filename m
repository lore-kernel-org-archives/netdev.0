From: Phil Oester <kernel@linuxace.com>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Tue, 1 Aug 2006 08:34:05 -0700
Message-ID: <20060801153405.GA6259@linuxace.com>
References: <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <44CE4DCA.8000609@trash.net> <20060801.000059.57444384.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-120-171-161.dsl.lsan03.pacbell.net ([67.120.171.161]:13843
	"HELO linuxace.com") by vger.kernel.org with SMTP id S1161024AbWHAPeG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 11:34:06 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060801.000059.57444384.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 12:00:59AM -0700, David Miller wrote:
>     What we have now is infinitely better than the past,
>     wherein all TSO packets were dropped due to corrupt
>     checksums as soon at the NAT module was loaded.

At what point did this problem begin?  2.6.18-rc or prior?

Phil
