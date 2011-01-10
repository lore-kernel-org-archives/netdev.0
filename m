From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2 1/2] can: add driver for Softing card
Date: Mon, 10 Jan 2011 14:44:43 +0100
Message-ID: <20110110134443.GB324@e-circ.dyndns.org>
References: <20110104150513.GA321@e-circ.dyndns.org>
	<20110104150759.GB321@e-circ.dyndns.org>
	<4D24DB2C.9040104@grandegger.com>
	<20110110133112.GA324@e-circ.dyndns.org>
	<20110110134006.GC31011@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110110134006.GC31011-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 10, 2011 at 02:40:06PM +0100, Wolfram Sang wrote:
> > > > +	if (type != 0xffff) {
> > > > +		dev_alert(&card->pdev->dev, "firware starts with type 0x%04x\n",
> > > 
> > > Typo?
> > > 
> > ??
> 
> I think he means "fir[m]ware"
> 
Thanks. Can't imagine anymore how I couldn't see it.

Kurt
