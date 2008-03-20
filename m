From: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH/RFC v3] introduce ARCH_CAN_UNALIGNED_ACCESS Kconfig symbol
Date: Thu, 20 Mar 2008 20:41:01 +0100
Message-ID: <20080320194101.GC17884@uranus.ravnborg.org>
References: <1206023695.16475.137.camel@johannes.berg> <20080320181310.GA17884@uranus.ravnborg.org> <1206038373.16475.150.camel@johannes.berg> <1206038734.16475.153.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Linux Kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1206038734.16475.153.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 20, 2008 at 07:45:34PM +0100, Johannes Berg wrote:
> Subject: introduce HAVE_UNALIGNED_ACCESS_SUPPORT Kconfig symbol
> 
> In many cases, especially in networking, it can be beneficial to
> know at compile time whether the architecture can do unaligned
> accesses. This patch introduces a new Kconfig symbol
> 	HAVE_UNALIGNED_ACCESS_SUPPORT
> for that purpose and adds it to the powerpc and x86 architectures.
> Also add some documentation about alignment and networking, and
> especially one intended use of this symbol.
> 
> Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Acked-by: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>

	Sam

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
