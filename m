From: "David S. Miller" <davem@redhat.com>
Subject: Re: [irda-users] [PATCH] Make VLSI FIR depend on X86
Date: Mon, 20 Oct 2003 21:17:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031020211706.5be33474.davem@redhat.com>
References: <Pine.GSO.4.58.0310171456080.13905@blinky>
	<Pine.LNX.4.44.0310201138020.4246-100000@notebook.home.mdiehl.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: noah@caltech.edu, irda-users@lists.sourceforge.net, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Diehl <lists@mdiehl.de>
In-Reply-To: <Pine.LNX.4.44.0310201138020.4246-100000@notebook.home.mdiehl.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Oct 2003 19:30:33 +0200 (CEST)
Martin Diehl <lists@mdiehl.de> wrote:

> Well, it would work with any arch, _if_ there was a way to sync the 
> streaming pci dma buffers before giving them back to hardware.

If pci_dma_sync() doesn't perform the operation you want, please
describe what that operation is.
