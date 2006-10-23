From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx-softmac: add PCI-E code
Date: Mon, 23 Oct 2006 15:29:05 +0200
Message-ID: <200610231529.05471.mb@bu3sch.de>
References: <45330803.mail261110C22@lwfinger.net>
	<200610202037.47758.mb@bu3sch.de> <453CC208.8010102@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>, John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
In-Reply-To: <453CC208.8010102-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 23 October 2006 15:22, Daniel Drake wrote:
> Michael Buesch wrote:
> > Please try 2.6.18.1 or wireless-2.6.
> > 
> 
> 
> 2.6.18.1 (with the PCI-E patch) crashes on modprobe:
> 
> bcm43xx driver
> ACPI: PCI Interrupt Link [LK1E] enabled at IRQ 11
> ACPI: PCI Interrupt 0000:03:00.0[A] -> Link [LK1E] -> GSI 11 (level, 
> low) -> IRQ 11
> PCI: Setting latency timer of device 0000:03:00.0 to 64
> bcm43xx: Could not determine Chip ID

Yeah, try to find out why.
I can only repeat myself: No developer has got a PCI-E card.
If there are problems, everybody has to find out by himself why
it does not work.
Try to find out why it can not determine the CHIP-ID.

-- 
Greetings Michael.
