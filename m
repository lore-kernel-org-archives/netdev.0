From: Xose Vazquez Perez <xose@wanadoo.es>
Subject: Re: [PATCH] tg3, more IDs
Date: Tue, 09 Dec 2003 18:23:14 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FD60502.5050300@wanadoo.es>
References: <3FD20895.2020605@wanadoo.es>	<3FD219FA.5010908@wanadoo.es> <20031208215657.550ba7e0.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> Applied,  but please next time remember to edit drivers/pci/pci.ids
> as well when adding new PCI device ids.

I usually send pci.ids updates to pciids.sf.net
Today it contains a _kilopatch_ of new entries, more than kernel_pci.ids

I was speaking with Martin Mares weeks ago to try that he did a 'commit'.
I don't know what happens with him. Does anyone know anything?

There are more pciids developers:

Dave Jones
Arjan van de Ven
Jeff Garzik
Lenz Grimmer
Martin Mares
Mike A. Harris
Bill Nottingham
Vojtech Pavlik

but until now, nobody cares about it.

Next time I will send it to you.

-thanks-
