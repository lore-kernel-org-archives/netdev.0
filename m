From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] ipip: fix sparse warnings in
 ipip_netlink_parms()
Date: Thu, 15 Nov 2012 05:20:02 -0800
Message-ID: <1352985602.4497.31.camel@edumazet-glaptop>
References: <1352969616-30476-1-git-send-email-nicolas.dichtel@6wind.com>
	 <50A4B8B0.1090409@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:50276 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767736Ab2KONUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 08:20:06 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so2122218iea.19
        for <netdev@vger.kernel.org>; Thu, 15 Nov 2012 05:20:05 -0800 (PST)
In-Reply-To: <50A4B8B0.1090409@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-15 at 10:41 +0100, Nicolas Dichtel wrote:
> Le 15/11/2012 09:53, Nicolas Dichtel a =C3=A9crit :
> > Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> I forget "Reported-by: Fengguang Wu <fengguang.wu@intel.com>"
>=20
> Should I resend the serie?

Your patches generally lack changelogs and proper attribution.

Having a good changelog can avoid to actually look at the patch content=
,
its incredibly useful in the long term.
