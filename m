From: Phil Blundell <philb@gnu.org>
Subject: Re: [PATCH] econet: remove compiler warnings
Date: Wed, 26 Jan 2011 14:19:59 +0100
Message-ID: <20110126131959.GF3010@hetzner>
References: <1296036258.2899.44.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-119-4.clients.your-server.de ([88.198.119.4]:44606
	"EHLO hetzner" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751400Ab1AZNyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 08:54:31 -0500
Content-Disposition: inline
In-Reply-To: <1296036258.2899.44.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 26, 2011 at 11:04:18AM +0100, Eric Dumazet wrote:
> net/econet/af_econet.c: In function =E2=80=98econet_sendmsg=E2=80=99:
> net/econet/af_econet.c:494: warning: label =E2=80=98error=E2=80=99 de=
fined but not used
> net/econet/af_econet.c:268: warning: unused variable =E2=80=98sk=E2=80=
=99
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks, looks sensible.

Acked-by: Phil Blundell <philb@gnu.org>

p.

