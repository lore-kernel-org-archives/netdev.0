From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] pci.ids for e1000
Date: Mon, 29 Sep 2003 23:25:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030929232520.0184a8f7.davem@redhat.com>
References: <3F621965.4070106@wanadoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Xose Vazquez Perez <xose@wanadoo.es>
In-Reply-To: <3F621965.4070106@wanadoo.es>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 12 Sep 2003 21:07:17 +0200
Xose Vazquez Perez <xose@wanadoo.es> wrote:

> Linus and Marcelo should not accept patches against pci.ids,
> all updates should go to pciids.sf.net. And every X time
> to do a sync with 2.4 and 2.6.

I don't know if this is the best idea.

When merging in a driver, it makes perfect sense to add the
appropriate device IDs to all PCI ID files.

On the other hand this could make life difficult for the
pciids.sf.net person.
