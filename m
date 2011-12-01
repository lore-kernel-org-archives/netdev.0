From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netconsole: implement ipv4 tos support
Date: Wed, 30 Nov 2011 22:37:03 -0500 (EST)
Message-ID: <20111130.223703.259122584986536045.davem@davemloft.net>
References: <1322702330-31325-1-git-send-email-zenczykowski@gmail.com>
	<20111130173435.5e63afda@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zenczykowski@gmail.com, maze@google.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58029 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753925Ab1LADhI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 22:37:08 -0500
In-Reply-To: <20111130173435.5e63afda@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 30 Nov 2011 17:34:35 -0800

> On Wed, 30 Nov 2011 17:18:50 -0800
> Maciej =AFenczykowski <zenczykowski@gmail.com> wrote:
>=20
>> From: Maciej =AFenczykowski <maze@google.com>
>>=20
>> Signed-off-by: Maciej =AFenczykowski <maze@google.com>
>=20
> Why make it an option? TOS should always be set to interactive
> traffic (like telnet and slogin)

Next they will ask for TTL as well.

Nope, sorry, we'll not be turning netconsole into a cluster-f*ck of
every configuration option anyone can come up with.
