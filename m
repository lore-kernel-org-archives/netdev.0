From: Daniel Drake <dsd@gentoo.org>
Subject: Re: netdev-2.6 queue updated
Date: Thu, 03 Mar 2005 20:20:37 +0000
Message-ID: <42277195.8@gentoo.org>
References: <4226BD3B.9080604@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@osdl.org>, philipp.gortan@tttech.com
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4226BD3B.9080604@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> <philipp.gortan:tttech.com>:
>   o [netdrvr 8139cp] add PCI ID

This one seems to be already present in 2.6.11 under a different name 
(PCI_DEVICE_ID_TTTECH_MC322). Also, the corresponding entry in pci_ids.h is 
not in the order of the file.

Daniel
