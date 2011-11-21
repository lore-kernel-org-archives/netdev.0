From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 01/17] netfilter: nf_nat: use hash random for bysource
 hash
Date: Mon, 21 Nov 2011 08:43:22 +0100
Message-ID: <1321861402.17419.9.camel@edumazet-laptop>
References: <1321854369-3432-1-git-send-email-kaber@trash.net>
	 <1321854369-3432-2-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ulrich.weber@sophos.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:51724 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753921Ab1KUHn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 02:43:27 -0500
In-Reply-To: <1321854369-3432-2-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 21 novembre 2011 =C3=A0 06:45 +0100, kaber@trash.net a =C3=A9c=
rit :
> From: Patrick McHardy <kaber@trash.net>
>=20
> Use nf_conntrack_hash_rnd in NAT bysource hash to avoid hash chain at=
tacks.
>=20
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
