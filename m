From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Fixes IW > 2 cases when TCP is application
 limited
Date: Fri, 04 Aug 2006 16:57:16 -0700 (PDT)
Message-ID: <20060804.165716.85394228.davem@davemloft.net>
References: <11546407561210-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:47833
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161587AbWHDX5M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 19:57:12 -0400
To: ilpo.jarvinen@helsinki.fi
In-Reply-To: <11546407561210-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Ilpo  J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Date: Fri, 04 Aug 2006 00:32:36 +0300

> Whenever a transfer is application limited, we are allowed at least
> initial window worth of data per window unless cwnd is previously
> less than that.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Looks good, applied.
