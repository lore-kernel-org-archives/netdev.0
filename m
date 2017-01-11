From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: marvell: fix Marvell 88E1512 used in SGMII mode
Date: Wed, 11 Jan 2017 10:03:23 -0500 (EST)
Message-ID: <20170111.100323.1789649822390190475.davem@davemloft.net>
References: <E1cR5bt-0000O8-1T@rmk-PC.armlinux.org.uk>
 <61950d83-cbe1-6e1b-4afc-bc471b386ff3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, rmk+kernel@armlinux.org.uk, netdev@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, charles-antoine.couret@nexvision.fr
To: f.fainelli@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <61950d83-cbe1-6e1b-4afc-bc471b386ff3@gmail.com>
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

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 10 Jan 2017 15:24:11 -0800

> Fixes: 6cfb3bcc0641 ("Marvell phy: check link status in case of fiber
> link.")

Thanks, I added this to Russell's commit message.
