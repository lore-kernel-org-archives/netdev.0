From: Geanta Neag Horia Ioan-B05471 <B05471@freescale.com>
Subject: iproute2 - IPsec ESN support
Date: Wed, 25 Jul 2012 06:14:52 +0000
Message-ID: <FD18E5D573A8AB48A365D4D78185DE992602BD@039-SN1MPN1-001.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Is there any way to create an IPsec tunnel and indicate using
extended sequnce numbers?

It seems that currently iproute2 doesn't support this.
Grepping for "esn" reveals that XFRM_STATE_ESN shows only in kernel headers.

The only relevant thing I found was a RFC sent by Steffen (Cc-ed),
but it was never applied (don't know why):
[RFC] iproute2: Add IPsec extended sequence number support
http://patchwork.ozlabs.org/patch/85962/

Thank you,
Horia
