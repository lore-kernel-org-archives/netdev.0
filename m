From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] Phonet: fix backlog callback return value
Date: Mon, 07 Mar 2011 12:31:24 -0800 (PST)
Message-ID: <20110307.123124.48505743.davem@davemloft.net>
References: <1299232831-3132-3-git-send-email-remi.denis-courmont@nokia.com>
	<20110307.122329.39193888.davem@davemloft.net>
	<201103072230.14080.remi@remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi@remlab.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41974
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752658Ab1CGUaq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 15:30:46 -0500
In-Reply-To: <201103072230.14080.remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi@remlab.net>
Date: Mon, 7 Mar 2011 22:30:13 +0200

> Le lundi 7 mars 2011 22:23:29 David Miller, vous avez =E9crit :
>> More verbose commit message please.
>>=20
>> What was wrong with the old error values and what exactly do
>> you claim to be doing to correct them?
>=20
> They were returning -Exxx errno's where the caller expected NET_RX_* =
values.

Then say that in the commit message.

