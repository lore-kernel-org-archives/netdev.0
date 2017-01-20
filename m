From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/2] Add support for the ethernet switch on the
 ESPRESSObin
Date: Fri, 20 Jan 2017 14:17:05 -0500 (EST)
Message-ID: <20170120.141705.1390880809796992457.davem@davemloft.net>
References: <20170119214934.27442-1-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, andrew@lunn.ch, f.fainelli@gmail.com,
 jason@lakedaemon.net, shjzhou@marvell.com, vivien.didelot@savoirfairelinux.com,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, jpannell@marvell.com,
 nadavh@marvell.com, kostap@marvell.com, dingwei@marvell.com,
 linux-arm-kernel@lists.infradead.org, sebastian.hesselbarth@gmail.com
To: gregory.clement@free-electrons.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170119214934.27442-1-gregory.clement@free-electrons.com>
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

From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Date: Thu, 19 Jan 2017 22:49:32 +0100

> I created a new family for this switch and filled the ops structure
> by selecting which seems the more appropriate functions. I rebased
> the series on net-next/master which allowed me to benefit to the
> eeprom functions introduced for the 6390.

It looks like there will be at least one more respin of this series,
specifically to remove the new family as Vivien seems to object to
this.
