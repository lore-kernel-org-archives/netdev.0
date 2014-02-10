From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix 'ip rule' iif/oif device rename
Date: Sun, 09 Feb 2014 19:03:28 -0800 (PST)
Message-ID: <20140209.190328.124034590484592594.davem@davemloft.net>
References: <1391819028-10722-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, netdev@vger.kernel.org, willemb@google.com,
	edumazet@google.com, chrismd@google.com, ccontavalli@google.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567AbaBJDD3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 22:03:29 -0500
In-Reply-To: <1391819028-10722-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Fri,  7 Feb 2014 16:23:48 -0800

> From: Maciej =AFenczykowski <maze@google.com>
>=20
> ip rules with iif/oif references do not update:
> (detach/attach) across interface renames.
>=20
> Signed-off-by: Maciej =AFenczykowski <maze@google.com>
> CC: Willem de Bruijn <willemb@google.com>
> CC: Eric Dumazet <edumazet@google.com>
> CC: Chris Davis <chrismd@google.com>
> CC: Carlo Contavalli <ccontavalli@google.com>
>=20
> Google-Bug-Id: 12936021

Applied and queued up for -stable, thanks.
