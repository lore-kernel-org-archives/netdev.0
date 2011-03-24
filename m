From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: RFC: [PATCH] can: c_can: disable one shot mode until driver is
	fixed
Date: Thu, 24 Mar 2011 11:52:29 +0100
Message-ID: <20110324105229.GC339@e-circ.dyndns.org>
References: <1300961549-28882-1-git-send-email-mkl@pengutronix.de>
	<20110324102852.GA339@e-circ.dyndns.org>
	<4D8B209E.5010907@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D8B209E.5010907-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

On Thu, Mar 24, 2011 at 11:44:46AM +0100, Marc Kleine-Budde wrote:
> On 03/24/2011 11:28 AM, Kurt Van Dijck wrote:
> > On Thu, Mar 24, 2011 at 11:12:29AM +0100, Marc Kleine-Budde wrote:
> >> This patch disables the one shot mode, until the driver has been fixed and
> >> tested to support it.
> >>
> > isn't this part necessary now (temporarily) to avoid dead code?
> 
> It's not necessary, the driver should still work.
Yep, I saw that.
> But it's dead code. If
> someone fixes the driver she/he can easily revert the patch.
> 
> Can I fold your patch and add your S-o-b?
Yes.
> 
Kurt
