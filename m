From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH v2] sit: Fix ipip6_tunnel_lookup device matching criteria
Date: Thu, 14 Aug 2014 14:03:28 +0200
Message-ID: <53ECA590.8030306@6wind.com>
References: <53EC8CA1.6060909@6wind.com> <1408013390-17273-1-git-send-email-shmulik.ladkani@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sascha Hlusiak <contact@saschahlusiak.de>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:48505 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901AbaHNMDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 08:03:31 -0400
Received: by mail-we0-f171.google.com with SMTP id p10so1004919wes.16
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 05:03:30 -0700 (PDT)
In-Reply-To: <1408013390-17273-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/08/2014 12:49, Shmulik Ladkani a =C3=A9crit :
> As of 4fddbf5d78 ("sit: strictly restrict incoming traffic to tunnel
> link device"), when looking up a tunnel, tunnel's underlying
Nitpicking, but David always asks to not split subject in two lines, ev=
en
if it's more than 80 columns.
