From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/11] net: usb: usbnet: add new api
 ethtool_{get|set}_link_ksettings
Date: Tue, 21 Mar 2017 16:03:40 -0700 (PDT)
Message-ID: <20170321.160340.2023320645829462653.davem@davemloft.net>
References: <1489702737-2401-1-git-send-email-tremyfr@gmail.com>
        <1489702737-2401-2-git-send-email-tremyfr@gmail.com>
        <1490095983.8154.8.camel@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tremyfr@gmail.com, allan@asix.com.tw, robert.foss@collabora.com,
        adobriyan@gmail.com, grundler@google.com,
        akpm@linux-foundation.org, gregkh@linuxfoundation.org,
        UNGLinuxDriver@microchip.com, peter.chen@nxp.com, jarod@redhat.com,
        stefan.bruens@rwth-aachen.de, steve.glendinning@shawell.net,
        jacmet@sunsite.dk, linux-kernel@vger.kernel.org,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: oneukum@suse.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490095983.8154.8.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Neukum <oneukum@suse.com>
Date: Tue, 21 Mar 2017 12:33:03 +0100

> Am Donnerstag, den 16.03.2017, 23:18 +0100 schrieb Philippe Reynes:
>> The ethtool api {get|set}_settings is deprecated.
>> We add the new api {get|set}_link_ksettings to this driver.
>> 
>> As I don't have the hardware, I'd be very pleased if
>> someone may test this patch.
>> 
> 
> Unfortunately I lack hardware to test.
> Phillipe and I had a patch collision. David, please take his
> patch for the next merge window. It looks good and is comprehensive and
> nobody has reported issues. We will never find testers for all those
> drivers on this list.

Ok.
