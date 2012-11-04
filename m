From: Lee Jones <lee.jones@linaro.org>
Subject: Re: [PATCH 9/9] Avoid 'statement with no effect' compiler warnings
Date: Sun, 4 Nov 2012 08:55:55 +0100
Message-ID: <20121104075555.GB24262@gmail.com>
References: <1351980150-24145-1-git-send-email-lee.jones@linaro.org>
 <1351980150-24145-10-git-send-email-lee.jones@linaro.org>
 <20121104.010043.1842614952525101679.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:50406 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533Ab2KDHz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2012 02:55:59 -0500
Received: by mail-ee0-f46.google.com with SMTP id b15so2424519eek.19
        for <netdev@vger.kernel.org>; Sun, 04 Nov 2012 00:55:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20121104.010043.1842614952525101679.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 04 Nov 2012, David Miller wrote:

> From: Lee Jones <lee.jones@linaro.org>
> Date: Sat,  3 Nov 2012 23:02:30 +0100
>=20
> > Instead of issuing (0) statements when !CONFIG_SYSFS which will cau=
se
> > 'warning: ', we'll use inline statements instead. This will effecti=
vely
> > do the same thing, but suppress any unnecessary warnings.
> >=20
> > Cc: Stephen Hemminger <shemminger@vyatta.com>
> > Cc: bridge@lists.linux-foundation.org
> > Cc: netdev@vger.kernel.org
> > Signed-off-by: Lee Jones <lee.jones@linaro.org>
>=20
> Applied, but please use more informative subject lines.
>=20
> You should prefix your subject line after [PATCH ...] with
> the name of the subsystem you are touching, a ": " then
> the headline description.
>=20
> So here you would have used "bridge: " and that's what I added when I
> commited this patch.

Yes, of course I should have done, and usually do.

This was an oversight, sorry about that.

--=20
Lee Jones
Linaro ST-Ericsson Landing Team Lead
Linaro.org =E2=94=82 Open source software for ARM SoCs
=46ollow Linaro: Facebook | Twitter | Blog
