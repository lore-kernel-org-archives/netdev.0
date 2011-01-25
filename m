From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v2 02/16] net: change netdev->features to u32
Date: Tue, 25 Jan 2011 12:07:45 +0100
Message-ID: <20110125110745.GA30979@rere.qmqm.pl>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl> <d9fe088556152bd3b43390e0fb5ea20d83aef233.1295734271.git.mirq-linux@rere.qmqm.pl> <20110124.153004.232756003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:45731 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751699Ab1AYLHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jan 2011 06:07:46 -0500
Content-Disposition: inline
In-Reply-To: <20110124.153004.232756003.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 24, 2011 at 03:30:04PM -0800, David Miller wrote:
> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Date: Sat, 22 Jan 2011 23:14:12 +0100 (CET)
> > Quoting Ben Hutchings: we presumably won't be defining features tha=
t
> > can only be enabled on 64-bit architectures.
> >=20
> > Occurences found by `grep -r` on net/, drivers/net, include/
> >=20
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> I'll apply this, with one change, adding the suggestion that
> features and vlan_features be moved next to each other in
> struct netdev, from Eric Dumazet.

You can use the one I sent in reply to Eric's suggestion.
It's this one: http://patchwork.ozlabs.org/patch/80056/

Best Regards,
Micha=B3 Miros=B3aw
