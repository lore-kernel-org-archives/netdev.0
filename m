From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 net-next 1/2] net: ethernet: slicoss: add slicoss
 gigabit ethernet driver
Date: Fri, 25 Nov 2016 10:59:47 +0100
Message-ID: <20161125095947.GA21048@kroah.com>
References: <1480029185-14140-1-git-send-email-LinoSanfilippo@gmx.de>
 <1480029185-14140-2-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, andrew@lunn.ch, f.fainelli@gmail.com,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, liodot@gmail.com,
 davem@davemloft.net
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1480029185-14140-2-git-send-email-LinoSanfilippo@gmx.de>
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

On Fri, Nov 25, 2016 at 12:13:04AM +0100, Lino Sanfilippo wrote:
> --- a/include/linux/pci_ids.h
> +++ b/include/linux/pci_ids.h
> @@ -2015,6 +2015,24 @@
>  #define PCI_SUBDEVICE_ID_CCD_OV4S	0xE888
>  #define PCI_SUBDEVICE_ID_CCD_OV8S	0xE998
>  
> +#define PCI_VENDOR_ID_ALACRITECH		0x139A
> +#define PCI_DEVICE_ID_ALACRITECH_MOAVE		0x0005

<snip>

Please read the top of this file for why you should not need to ever
modify this file again :)

thanks,

greg k-h
