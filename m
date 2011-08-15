From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH v12 3/6] flexcan: Fix up fsl-flexcan device tree binding.
Date: Mon, 15 Aug 2011 10:25:40 -0500
Message-ID: <20110815152540.GP4926@sgi.com>
References: <1313138752-24006-1-git-send-email-holt@sgi.com>
	<1313138752-24006-4-git-send-email-holt@sgi.com>
	<20110815150357.GM4926@sgi.com>
	<CACxGe6vafc6mYyKCAO+HqkRPsZ3GmeVJnK+z8=BX_wQQMG4LmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CACxGe6vafc6mYyKCAO+HqkRPsZ3GmeVJnK+z8=BX_wQQMG4LmQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Mon, Aug 15, 2011 at 09:13:50AM -0600, Grant Likely wrote:
> On Mon, Aug 15, 2011 at 9:03 AM, Robin Holt <holt-sJ/iWh9BUns@public.gmane.org> wrote:
> > Grant,
> >
> > Earlier, you had asked for a more specific name for the compatible
> > property of the Freescale flexcan device. =A0I still have not gotten a
> > more specific answer. =A0Hopefully Marc can give you more details about
> > the flexcan implementations.
> =

> If there is no ip core version, then just stick with the
> fsl,<soc>-flexcan name and drop "fsl,flexcan".  Marketing may say
> flexcan is flexcan, but hardware engineers like to change things.
> Trying to be too generic in compatible values will just lead to
> problems in the future.

Thanks,
Robin
