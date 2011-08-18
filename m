From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-2.6] via-velocity: remove non-tagged packet
 filtering
Date: Wed, 17 Aug 2011 20:14:03 -0700 (PDT)
Message-ID: <20110817.201403.869549938536852264.davem@davemloft.net>
References: <1313483614-2188-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	romieu@fr.zoreil.com, stephan.baerwolf@tu-ilmenau.de
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42971 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754805Ab1HRDOO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 23:14:14 -0400
In-Reply-To: <1313483614-2188-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 16 Aug 2011 10:33:34 +0200

> It's undesired to filter untagged packets at any time. So simply remo=
ve this.
>=20
> Reported-by: Stephan B=E4rwolf <stephan.baerwolf@tu-ilmenau.de>
> Tested-by: Stephan B=E4rwolf <stephan.baerwolf@tu-ilmenau.de>
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks.
