From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.24] [TCP]: Fix fastpath_cnt_hint when GSO skb
 is partially ACKed
Date: Sun, 07 Oct 2007 23:39:26 -0700 (PDT)
Message-ID: <20071007.233926.31663362.davem@davemloft.net>
References: <Pine.LNX.4.64.0710031817540.27745@kivilampi-30.cs.helsinki.fi>
	<4704FE75.2030104@fr.ibm.com>
	<Pine.LNX.4.64.0710041911400.17326@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: clg@fr.ibm.com, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37395
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752508AbXJHGj1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2007 02:39:27 -0400
In-Reply-To: <Pine.LNX.4.64.0710041911400.17326@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 4 Oct 2007 23:20:34 +0300 (EEST)

> Dave should apply both the three patch series fix and this one as wel=
l to=20
> net-2.6.24 (Dave, in case you want me to resubmit, just ask... :-)). =
I'll=20
> send one against .23-rc9 soon after this (sadly enough, it will cause=
 a=20
> conflict...).

Ok, all the net-2.6.24 bits are in, I'll take care of -stable...
