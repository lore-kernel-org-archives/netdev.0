From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/2] net/macb: add DT support for Cadence macb/gem
 driver
Date: Wed, 07 Dec 2011 13:27:39 -0500 (EST)
Message-ID: <20111207.132739.335219058075173468.davem@davemloft.net>
References: <1322847782-22650-1-git-send-email-nicolas.ferre@atmel.com>
 <714ca7492d8d45b50eab34448c4b70933ce5701c.1323086095.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
 linux-kernel@vger.kernel.org, grant.likely@secretlab.ca, jamie@jamieiles.com,
 plagnioj@jcrosoft.com, linux-arm-kernel@lists.infradead.org
To: nicolas.ferre@atmel.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <714ca7492d8d45b50eab34448c4b70933ce5701c.1323086095.git.nicolas.ferre@atmel.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Mon,  5 Dec 2011 12:59:52 +0100

> From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> 
> Allow the device tree to provide the mac address and the phy mode.
> 
> Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> [nicolas.ferre@atmel.com: change "compatible" node property, doc and DT hwaddr]
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> [jamie@jamieiles.com: add "gem" compatibility strings and doc]
> Acked-by: Jamie Iles<jamie@jamieiles.com>

Acked-by: David S. Miller <davem@davemloft.net>
