From: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH] usb/net/asix_devices: Add USBNET HG20F9 ethernet dongle
Date: Mon, 25 Feb 2013 20:23:43 -0800
Message-ID: <20130226042343.GA27766@kroah.com>
References: <1361852232.23197.4.camel@andromache.adelaide.aarnet.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Glen Turner <gdt-pRLresKaOUyHXe+LvDLADg@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1361852232.23197.4.camel-MFjF70HZCXOiAIzqYCf0vryL0Hf3YRqg06D/hhiQN/qHXe+LvDLADg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 26, 2013 at 02:47:12PM +1030, Glen Turner wrote:
> This USB ethernet adapter was purchased in anodyne packaging
> marked "USB2.0 to LAN" from the computer store adjacent to
> linux.conf.au 2013 in Canberra (Australia). A web search
> shows other recent purchasers in Lancaster (UK) and Seattle
> (USA). Just like an emergent virus, our age of e-commerce and
> airmail allows underdocumented hardware to spread around the
> world instantly using the vector of ridiculously low prices.
> 
> Paige Thompson, infected via eBay, discovered that the HG20F9
> is a copy of the Asix 88772B; many viruses copy the RNA of
> other viruses. See Paige's work at
> <https://github.com/paigeadele/HG20F9>.
> This patch uses her discovery to update the restructured Asix
> driver in the current kernel.
> 
> The spread of viruses is often accompanied by rumours. It is
> rumoured that the HG20F9 has extensions to to provide gigabit
> ethernet. This patch does not chase that chimera.
> 
> Just as some viruses inhabit seemingly-healthy cells, the
> HG20F9 uses the Vendor ID 0x066b assigned to Linksys Inc.
> For the present there is no clash of Product ID 0x20f9.
> 
> Signed-off-by: Glen Turner <gdt-pRLresKaOUyHXe+LvDLADg@public.gmane.org>

That is the best "add a new device id" changelog entry I have _ever_
seen.  Wonderful job:

Acked-by: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
