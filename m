From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/6] drivers: net: xgene-v2: Add RGMII based 1G
 driver
Date: Tue, 31 Jan 2017 21:06:17 +0100
Message-ID: <20170131200617.GN5656@lunn.ch>
References: <1485889401-13909-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51693 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752130AbdAaUGT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 15:06:19 -0500
Content-Disposition: inline
In-Reply-To: <1485889401-13909-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2017 at 11:03:15AM -0800, Iyappan Subramanian wrote:
> This patch set adds support for RGMII based 1GbE hardware which uses a linked
> list of DMA descriptor architecture (v2) for APM X-Gene SoCs.

Hi Iyappan

Should we assume there are more patches to follow adding MDIO bus
support and phylib integration?

	Andrew
