From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: netdev-2.6 queue updated
Date: Fri, 04 Mar 2005 00:11:08 -0500
Message-ID: <4227EDEC.3040606@pobox.com>
References: <4226BD3B.9080604@pobox.com> <42277195.8@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@osdl.org>, philipp.gortan@tttech.com
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <42277195.8@gentoo.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Daniel Drake wrote:
> Jeff Garzik wrote:
> 
>> <philipp.gortan:tttech.com>:
>>   o [netdrvr 8139cp] add PCI ID
> 
> 
> This one seems to be already present in 2.6.11 under a different name 
> (PCI_DEVICE_ID_TTTECH_MC322). Also, the corresponding entry in pci_ids.h 
> is not in the order of the file.

BitKeeper will fix that up at merge time.

	Jeff
