From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] [TCP]: Uninline tcp_set_state
Date: Sat, 12 Jan 2008 03:18:35 -0800 (PST)
Message-ID: <20080112.031835.135447964.davem@davemloft.net>
References: <12001304691600-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12001304691978-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46650
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759043AbYALLSf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 06:18:35 -0500
In-Reply-To: <12001304691978-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 12 Jan 2008 11:34:22 +0200

> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks.

> +#endif=09
> +}
> +EXPORT_SYMBOL_GPL(tcp_set_state);

I fixed up the trailing whitespace on the "#endif" line.
