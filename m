From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 3/5] sis900 printk and stack usage audit
Date: Sat, 11 Dec 2004 14:09:52 -0500
Message-ID: <41BB4600.3010409@pobox.com>
References: <20041208104721.GA31707@picchio.gall.it> <20041208110610.GD31707@picchio.gall.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniele Venzano <webvenza@libero.it>
In-Reply-To: <20041208110610.GD31707@picchio.gall.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Daniele Venzano wrote:
> Chip revision is now a member of sis_priv structure
> Kill all calls to pci_read_config_byte but one
> Change the code to use sis_priv->chipset_rev

OK (but not applied, since previous patches in series were not applied)
