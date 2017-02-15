From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/2] net: xilinx_emaclite: fix receive buffer overflow
Date: Wed, 15 Feb 2017 15:31:43 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFE673AC@AcuExch.aculab.com>
References: <20170214171145.26953-1-anssi.hannula@bitwise.fi>
 <20170214.151259.1157334352658192111.davem@davemloft.net>
 <62dad5ad-cafb-7569-b010-cb355f7affc7@bitwise.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "michal.simek@xilinx.com" <michal.simek@xilinx.com>,
        "soren.brinkmann@xilinx.com" <soren.brinkmann@xilinx.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Anssi Hannula' <anssi.hannula@bitwise.fi>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.193]:65239 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbdBOPbv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 10:31:51 -0500
In-Reply-To: <62dad5ad-cafb-7569-b010-cb355f7affc7@bitwise.fi>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anssi Hannula
> Sent: 15 February 2017 08:29
...
> Looking through the product guide [1] I don't see the actual receive
> packet length provided anywhere, so I guess that is why the crazy stuff
> is done.

If the hardware doesn't provide the receive packet length then I suggest
you 'fix' the hardware with an angle grinder :-)
Not fit for purpose.

	David
