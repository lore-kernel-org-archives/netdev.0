From: Nishanth Menon <nm@ti.com>
Subject: Re: [PATCH V2] net: micrel : ks8851-ml: add vdd-supply support
Date: Fri, 21 Mar 2014 04:30:04 -0500
Message-ID: <532C069C.7060208@ti.com>
References: <20140321085158.GB30910@pengutronix.de>
 <1395394080-28964-1-git-send-email-nm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Tony Lindgren <tony@atomide.com>,
 netdev@vger.kernel.org, Markus Pargmann <mpa@pengutronix.de>,
 Russell King <rmk+kernel@arm.linux.org.uk>, linux-omap@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1395394080-28964-1-git-send-email-nm@ti.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 03/21/2014 04:28 AM, Nishanth Menon wrote:

> +	ks->vdd_reg = regulator_get_optional(&spi->dev, "vdd");
ok, that is unbelievable.. no git commit --amend :(.. Apologies on the
spam.. will resent.


-- 
Regards,
Nishanth Menon
