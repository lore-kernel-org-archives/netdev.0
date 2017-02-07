From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] sierra_net: Skip validating irrelevant fields
 for IDLE LSIs
Date: Tue, 07 Feb 2017 13:53:18 -0500 (EST)
Message-ID: <20170207.135318.64837214500819399.davem@davemloft.net>
References: <20170207023317.29192-1-stefan.bruens@rwth-aachen.de>
        <cbb609c5c4154e5ca463edc5aa390bd6@rwthex-w2-b.rwth-ad.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: stefan.bruens@rwth-aachen.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cbb609c5c4154e5ca463edc5aa390bd6@rwthex-w2-b.rwth-ad.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Brüns <stefan.bruens@rwth-aachen.de>
Date: Tue, 7 Feb 2017 03:33:17 +0100

> When the context is deactivated, the link_type is set to 0xff, which
> triggers a warning message, and results in a wrong link status, as
> the LSI is ignored.
> 
> Signed-off-by: Stefan Brüns <stefan.bruens@rwth-aachen.de>

Applied.
