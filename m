From: David Miller <davem@davemloft.net>
Subject: Re: ip rule and/or route problem in 2.6.37-rc5+
Date: Thu, 23 Dec 2010 12:06:32 -0800 (PST)
Message-ID: <20101223.120632.245389028.davem@davemloft.net>
References: <20101219.214230.39170893.davem@davemloft.net>
	<AANLkTikNk8Ltei+jxpJuVqNxbhc-hhMpjc89YDvbirQK@mail.gmail.com>
	<AANLkTin0mNkfaDvs3ZrEhxY27kdmZLh8ikKNpc-MXC44@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, greearb@candelatech.com,
	netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54147
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751418Ab0LWUGC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Dec 2010 15:06:02 -0500
In-Reply-To: <AANLkTin0mNkfaDvs3ZrEhxY27kdmZLh8ikKNpc-MXC44@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Thu, 23 Dec 2010 10:22:23 +0100

> Could we please revert this ( 4465b469008bc03b98a1b8df4e9ae501b6c69d4=
b
> ) and make sure the revert makes it into 2.6.37?  We definitely don't
> want to ship 2.6.37 with this patch in its current state.

I'm pushing out a revert right now, thanks everyone.
