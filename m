From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] tg3, more IDs
Date: Mon, 8 Dec 2003 21:56:57 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031208215657.550ba7e0.davem@redhat.com>
References: <3FD20895.2020605@wanadoo.es>
	<3FD219FA.5010908@wanadoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Xose Vazquez Perez <xose@wanadoo.es>
In-Reply-To: <3FD219FA.5010908@wanadoo.es>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 06 Dec 2003 19:03:38 +0100
Xose Vazquez Perez <xose@wanadoo.es> wrote:

> forget my last patch, here goes one more complete:

Applied,  but please next time remember to edit drivers/pci/pci.ids
as well when adding new PCI device ids.
