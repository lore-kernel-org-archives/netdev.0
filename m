From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] [XFRM] xfrm_policy: kill some bloat
Date: Sat, 12 Jan 2008 03:20:11 -0800 (PST)
Message-ID: <20080112.032011.145168198.davem@davemloft.net>
References: <12001304691978-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1200130469783-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12001304693917-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49735
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759404AbYALLUL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 06:20:11 -0500
In-Reply-To: <12001304693917-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 12 Jan 2008 11:34:24 +0200

> net/xfrm/xfrm_policy.c:
>   xfrm_audit_policy_delete | -692
>   xfrm_audit_policy_add    | -692
>  2 functions changed, 1384 bytes removed, diff: -1384
>=20
> net/xfrm/xfrm_policy.c:
>   xfrm_audit_common_policyinfo | +704
>  1 function changed, 704 bytes added, diff: +704
>=20
> net/xfrm/xfrm_policy.o:
>  3 functions changed, 704 bytes added, 1384 bytes removed, diff: -680
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
