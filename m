From: Alan Cox <alan@redhat.com>
Subject: Re: [PATCH] Re: VIA "Velocity" Gigabit ethernet driver
Date: Mon, 31 May 2004 19:01:34 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040531230134.GC31056@devserv.devel.redhat.com>
References: <20040526174018.GA29119@devserv.devel.redhat.com> <20040601003503.A19358@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20040601003503.A19358@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 01, 2004 at 12:35:03AM +0200, Francois Romieu wrote:
> Some polish attached. I'll probably do the rx_copybreak thing as well as
> some pci_dma_sync_single_for_{cpu/device} if nobody beats me.
> 
> Apparently there's no documentation available for the chipset, right ?

I have some documentation but its not what I would call complete. The docs are
marked NDA etc etc but identical to the ones you'll find included with the
current driver zip (the .exe is also a zip) on viaarena ;)
