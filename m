From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: Gigabit ethernet driver for Alacritechs SLIC devices (v3)
Date: Sat, 26 Nov 2016 13:36:35 +0100
Message-ID: <80734dd5-900f-07b7-3b96-dbd5cac61291@gmx.de>
References: <1480162850-8014-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
To: davem@davemloft.net, charrer@alacritech.com, liodot@gmail.com,
 gregkh@linuxfoundation.org, andrew@lunn.ch
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1480162850-8014-1-git-send-email-LinoSanfilippo@gmx.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On 26.11.2016 13:20, Lino Sanfilippo wrote:

> v3:
> - dont add defines to pci.h but instead put it into the drivers header file

This should of course be "pci_ids.h".

Regards,
Lino
