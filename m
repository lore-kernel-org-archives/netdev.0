From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netem: update backlog after drop
Date: Fri, 11 Oct 2013 14:30:18 -0400 (EDT)
Message-ID: <20131011.143018.1801127237009991334.davem@davemloft.net>
References: <20131006151533.52988624@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754780Ab3JKSaU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 14:30:20 -0400
In-Reply-To: <20131006151533.52988624@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stephen Hemminger <stephen@networkplumber.org>
Date: Sun, 6 Oct 2013 15:15:33 -0700

> When packet is dropped from rb-tree netem the backlog statistic shoul=
d
> also be updated.
>=20
> Reported-by: =F3=C5=D2=C7=C5=C5=D7 =F3=C5=D2=C7=C5=CA <adron@yapic.ne=
t>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>=20
> ---
> Should be reviewed by Eric (he added the rb-tree stuff), and added to=
 stable
> as well.

Eric please review this patch, thanks.
