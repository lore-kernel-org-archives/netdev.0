From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH] iproute: Fix Netid value for multi-families output
Date: Wed, 29 Jan 2014 11:29:02 -0800 (PST)
Message-ID: <1391023742.70240.YahooMailBasic@web125505.mail.ne1.yahoo.com>
References: <52E74D0F.4050806@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm32.bullet.mail.ne1.yahoo.com ([98.138.229.25]:26269 "EHLO
	nm32.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751040AbaA2Tby convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jan 2014 14:31:54 -0500
In-Reply-To: <52E74D0F.4050806@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1/28/14, Pavel Emelyanov <xemul@parallels.com> wrote:

> When requesting simultaneous output of TCP and UDP sockets
> the netid field shows "tcp" always.

[...]

> Reported-by: Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

> ---

Tested-by: Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>
