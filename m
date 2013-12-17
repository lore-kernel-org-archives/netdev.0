From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] ipv6_get_ifaddr(), alway called with strict =1
Date: Tue, 17 Dec 2013 16:09:02 +0100
Message-ID: <20131217150902.GD18396@order.stressinduktion.org>
References: <1387224452.59094.YahooMailBasic@web125502.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?utf-8?Q?Fran=C3=A7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33631 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185Ab3LQPJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 10:09:03 -0500
Content-Disposition: inline
In-Reply-To: <1387224452.59094.YahooMailBasic@web125502.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 16, 2013 at 12:07:32PM -0800, Fran=C3=A7ois-Xavier Le Bail =
wrote:
> Hi,
>=20
> Doubtless, this argument is no more usefull.
>=20
> Any reason to keep it ?

Propose a patch if you are sure it really isn't needed. A quick look fr=
om my
side doesn't show potential future use cases.

Greetings,

  Hannes
