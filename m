From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 2/5] net: mvmdio: rename base register cookie from
 smireg to regs
Date: Tue, 29 Jan 2013 16:34:05 +0100
Message-ID: <20130129163405.15415166@skate>
References: <1359473048-26551-1-git-send-email-florian@openwrt.org>
	<1359473048-26551-3-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King <linux@arm.linux.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1359473048-26551-3-git-send-email-florian@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Florian Fainelli,

On Tue, 29 Jan 2013 16:24:05 +0100, Florian Fainelli wrote:
> This patch renames the base register cookie in the mvmdio drive from
> "smireg" to "regs" since a subsequent patch is going to use an ioremap()
> cookie whose size is larger than a single register of 4 bytes. No
> functionnal code change introduced.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Acked-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
