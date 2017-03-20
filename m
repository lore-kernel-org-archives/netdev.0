From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH 01/11] net: usb: usbnet: add new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 20 Mar 2017 07:39:51 +0100
Message-ID: <1489991991.1380.0.camel@suse.com>
References: <1489702737-2401-1-git-send-email-tremyfr@gmail.com>
         <1489702737-2401-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>, allan@asix.com.tw,
        robert.foss@collabora.com, davem@davemloft.net,
        adobriyan@gmail.com, grundler@google.com,
        akpm@linux-foundation.org, gregkh@linuxfoundation.org,
        UNGLinuxDriver@microchip.com, peter.chen@nxp.com, jarod@redhat.com,
        stefan.bruens@rwth-aachen.de, steve.glendinning@shawell.net,
        jacmet@sunsite.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489702737-2401-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Donnerstag, den 16.03.2017, 23:18 +0100 schrieb Philippe Reynes:
> The ethtool api {get|set}_settings is deprecated.
> We add the new api {get|set}_link_ksettings to this driver.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
Acked-by: Oliver Neukum <oneukum@suse.com>
