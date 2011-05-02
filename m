From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [PATCH v4 5/5] iproute2: add can-j1939 support
Date: Mon, 2 May 2011 15:36:00 +0200
Message-ID: <20110502133600.GE338@e-circ.dyndns.org>
References: <20110427085330.GA757@kurt.e-circ.dyndns.org>
	<20110427090302.GF757@kurt.e-circ.dyndns.org>
	<4DBEAFC6.7010308@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4DBEAFC6.7010308-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

On Mon, May 02, 2011 at 03:21:10PM +0200, Marc Kleine-Budde wrote:
> On 04/27/2011 11:03 AM, Kurt Van Dijck wrote:
> > Add j1939 support to iproute2
> > 
> > Signed-off-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
> > -CCOPTS = -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall
>                           ^^^^
> 
> why do you remove -O2?

I did -O0 for debugging, but must have forgotten to properly restore.
I need to fix this for a definite version.

Thanks,
Kurt
