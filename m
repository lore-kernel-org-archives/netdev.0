From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] fsl/fman: remove of_node
Date: Wed, 4 Oct 2017 15:09:42 +0200
Message-ID: <20171004130942.GL30045@lunn.ch>
References: <1506940297-20442-1-git-send-email-madalin.bucur@nxp.com>
 <20171002.160445.737065995396076298.davem@davemloft.net>
 <AM5PR0402MB26914CBD37E3F28C17562258EC720@AM5PR0402MB2691.eurprd04.prod.outlook.com>
 <20171003130032.GI13548@lunn.ch>
 <AM5PR0402MB2691DAD9404B336D92F42ED9EC730@AM5PR0402MB2691.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Madalin-cristian Bucur <madalin.bucur@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AM5PR0402MB2691DAD9404B336D92F42ED9EC730@AM5PR0402MB2691.eurprd04.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Does DSA work for systems that do not use a device tree to boot, i.e. ACPI?

ACPI is not supported. So far, nobody has built a board using ACPI and
Ethernet switches supported by DSA.

	 Andrew
