From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] sierra_net: Add support for IPv6 and Dual-Stack
 Link Sense Indications
Date: Tue, 07 Feb 2017 13:53:12 -0500 (EST)
Message-ID: <20170207.135312.2024064918721070962.davem@davemloft.net>
References: <20170207023317.29192-1-stefan.bruens@rwth-aachen.de>
        <94f1dec53f614c76802adf350f495922@rwthex-w2-b.rwth-ad.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: stefan.bruens@rwth-aachen.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <94f1dec53f614c76802adf350f495922@rwthex-w2-b.rwth-ad.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Brüns <stefan.bruens@rwth-aachen.de>
Date: Tue, 7 Feb 2017 03:33:16 +0100

> If a context is configured as dualstack ("IPv4v6"), the modem indicates
> the context activation with a slightly different indication message.
> The dual-stack indication omits the link_type (IPv4/v6) and adds
> additional address fields.
> IPv6 LSIs are identical to IPv4 LSIs, but have a different link type.
> 
> Signed-off-by: Stefan Brüns <stefan.bruens@rwth-aachen.de>

Applied.

Ignore my earlier comments about the UMTS comment, it is still
accurate of course. :-)
