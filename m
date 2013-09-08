From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net 1/1] r8169: enforce RX_MULTI_EN for the 8168f.
Date: Sun, 08 Sep 2013 10:45:14 +0200
Message-ID: <522C391A.3020408@redhat.com>
References: <20130907231535.GB24530@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	David R <david@unsolicited.net>,
	=?UTF-8?B?RnLDqWTDqXJpYyBMZXJveQ==?= <fredo@starox.org>,
	Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38499 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837Ab3IHIph (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Sep 2013 04:45:37 -0400
In-Reply-To: <20130907231535.GB24530@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2013 01:15 AM, Francois Romieu wrote:
> Same narrative as eb2dc35d99028b698cdedba4f5522bc43e576bd2 ("r8169: R=
xConfig
> hack for the 8168evl.") regarding AMD IOMMU errors.
>
> RTL_GIGA_MAC_VER_36 - 8168f as well - has not been reported to behave=
 the
> same.
>
> Tested-by: David R <david@unsolicited.net>
> Tested-by: Fr=C3=A9d=C3=A9ric Leroy <fredo@starox.org>
> Cc: Hayes Wang <hayeswang@realtek.com>
> ---

Your signed-off-by is missing.
