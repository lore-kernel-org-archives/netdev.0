From: "Masayuki Ohtake" <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Tue, 14 Sep 2010 17:48:43 +0900
Message-ID: <00ca01cb53e9$a50c1930$66f8800a@maildom.okisemi.com>
References: <4C61EDE5.4030505@dsn.okisemi.com>
	<4C629FE5.6000204@pengutronix.de>
	<005f01cb533e$5c21d530$66f8800a@maildom.okisemi.com>
	<20100913152204.GA24088@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Morinaga <morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>, meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org,
	arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: "Greg KH" <gregkh-l3A5Bk7waGM@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
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

Hi Greg,

> Then try setting up a Linux server to handle email issues to prevent
> patches from going through Exchange, which is known to corrupt patches.
We want to use "git send-email".
I have already installed "git send-email".
What's else setting we need ?

Thanks, Ohtake(OKISemi)
----- Original Message ----- 
From: "Greg KH" <gregkh-l3A5Bk7waGM@public.gmane.org>
To: "Masayuki Ohtake" <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Cc: "Marc Kleine-Budde" <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>; <meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org>; "Wolfgang Grandegger" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>;
<socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>; <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; <andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>;
<qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; <yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; "Morinaga" <morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Sent: Tuesday, September 14, 2010 12:22 AM
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35


> On Mon, Sep 13, 2010 at 09:07:44PM +0900, Masayuki Ohtake wrote:
> > > - Try to send patches directly with git send-email
> > In our network environment, we can't use send-email.
>
> Then try setting up a Linux server to handle email issues to prevent
> patches from going through Exchange, which is known to corrupt patches.
> Lots of other companies do this for Linux development, including
> Microsoft :)
>
> thanks,
>
> greg k-h
>
