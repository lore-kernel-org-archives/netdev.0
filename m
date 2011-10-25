From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make bonding slaves honour master's skb->priority
Date: Tue, 25 Oct 2011 00:58:59 -0400 (EDT)
Message-ID: <20111025.005859.101223081342927863.davem@davemloft.net>
References: <1319517660-22085-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50261 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651Ab1JYE7C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 00:59:02 -0400
In-Reply-To: <1319517660-22085-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Mon, 24 Oct 2011 21:41:00 -0700

> From: Maciej =AFenczykowski <maze@google.com>
>=20
> Change-Id: Ieea6ff9aacacb1eb8c52308c8bfe091acbfc09b2

What are these Change-Id tags?  Please don't put these in
your commit message.

I'm dropping this patch, you'll need to resubmit it without
this thing.
