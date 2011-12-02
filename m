From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/macb: add DT support
Date: Fri, 02 Dec 2011 12:58:32 -0500 (EST)
Message-ID: <20111202.125832.1208514279272697863.davem@davemloft.net>
References: <1322846050-4543-1-git-send-email-nicolas.ferre@atmel.com>
 <1322847782-22650-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
 linux-kernel@vger.kernel.org, grant.likely@secretlab.ca, jamie@jamieiles.com,
 plagnioj@jcrosoft.com, linux-arm-kernel@lists.infradead.org
To: nicolas.ferre@atmel.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1322847782-22650-1-git-send-email-nicolas.ferre@atmel.com>
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
Date: Fri,  2 Dec 2011 18:43:02 +0100

> From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> 
> Allow the device tree to provide the mac address and the phy mode.
> 
> Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> [nicolas.ferre@atmel.com: change "compatible" node property, doc and DT hwaddr]
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> Cc: Jamie Iles <jamie@jamieiles.com>
> ---
> v2: modify macb_get_hwaddr_dt() parameter

You'll have to respin these two macb patches, as they don't apply properly
to the net-next tree which is where they should be targetted.

Thanks.
