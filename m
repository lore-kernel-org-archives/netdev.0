From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 0/2] [TCP]: Fix bidirectional brokeness
Date: Mon, 30 Jul 2007 19:54:24 -0700 (PDT)
Message-ID: <20070730.195424.45876304.davem@davemloft.net>
References: <Pine.LNX.4.64.0707301947210.8788@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40537
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755120AbXGaCyc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 22:54:32 -0400
In-Reply-To: <Pine.LNX.4.64.0707301947210.8788@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 30 Jul 2007 20:16:54 +0300 (EEST)

> These will generate you some hassle when you rebase tcp-2.6. Btw, you=
=20
> forgot to push tcp-2.6 out last time though I could assume it's
> state... :-) In case you're going to now push it out, could you pleas=
e
> drop "[TCP]: Remove num_acked>0 checks from cong.ctrl mods pkts_acked=
"
> from it as it seems to be out of place in tcp-2.6, I can resubmit it
> to net-2.6.24 when you open it (unless you want to put it to net-2.6=20
> directly as it's rather trivial one).

It has been in the back of my mind to take care of the tcp-2.6
tree and rebase it for you and others.

I'll take a stab at that soon hopefully.

Thanks for reminding me.
