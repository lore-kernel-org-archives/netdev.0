From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9] [TCP]: clear_all_retrans_hints prefixed by tcp_
Date: Thu, 20 Sep 2007 11:31:12 -0700 (PDT)
Message-ID: <20070920.113112.10246803.davem@davemloft.net>
References: <11902906721846-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11902906723619-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11902906723822-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57165
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753235AbXITSbM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 14:31:12 -0400
In-Reply-To: <11902906723822-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 20 Sep 2007 15:17:46 +0300

> In addition, fix its function comment spacing.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.

> -/*from STCP */
> -static inline void clear_all_retrans_hints(struct tcp_sock *tp){
> +/* from STCP */
> +static inline void tcp_clear_all_retrans_hints(struct tcp_sock *tp) =
{

This brace should also be on a line by itself.
