From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 1/2] net: ethernet: cpsw: Search childs for slave nodes
Date: Fri, 4 Oct 2013 08:27:59 -0500
Message-ID: <524EC25F.70301@ti.com>
References: <1380890680-30941-1-git-send-email-mpa@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, netdev@vger.kernel.org,
 Florian Fainelli <florian@openwrt.org>, linux-arm-kernel@lists.infradead.org
To: Markus Pargmann <mpa@pengutronix.de>, "David S. Miller"
 <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1380890680-30941-1-git-send-email-mpa@pengutronix.de>
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

On Friday 04 October 2013 07:44 AM, Markus Pargmann wrote:
> The current implementation searches the whole DT for nodes named
> "slave".
>
> This patch changes it to search only child nodes for slaves.
>
> Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
