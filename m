From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/4] addrgenmode updates for net-next
Date: Wed, 6 Jan 2016 09:23:33 -0800
Message-ID: <20160106092333.73ec23e7@xeon-e3>
References: <1451901486-3497-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: =?UTF-8?B?QmrDuHJu?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34091 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751940AbcAFRXZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 12:23:25 -0500
Received: by mail-pa0-f53.google.com with SMTP id uo6so218039738pac.1
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 09:23:25 -0800 (PST)
In-Reply-To: <1451901486-3497-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  4 Jan 2016 10:58:02 +0100
Bj=C3=B8rn Mork <bjorn@mork.no> wrote:

> This adds support for the new "random" addrgenmode in net-next
> and improves the support for the "stable_secret" mode.
>=20
> Bj=C3=B8rn Mork (4):
>   include: update kernel headers
>   iplink: support setting addrgenmode stable_secret
>   iplink: support show and set of "addrgenmode random"
>   man: iplink: document new addrgenmodes
>=20
>  include/linux/if_link.h |  1 +
>  ip/ipaddress.c          |  3 +++
>  ip/iplink.c             |  6 +++++-
>  man/man8/ip-link.8.in   | 18 +++++++++++++++---
>  4 files changed, 24 insertions(+), 4 deletions(-)
>=20

Applied to net-next branch.
