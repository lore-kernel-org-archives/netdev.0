From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 3/4] ipv4: add option to drop gratuitous ARP packets
Date: Wed, 04 Nov 2015 17:19:53 +0100
Message-ID: <1446653993.17416.3.camel@sipsolutions.net>
References: <1428652454-1224-1-git-send-email-johannes@sipsolutions.net>
	 <1428652454-1224-3-git-send-email-johannes@sipsolutions.net>
	 <alpine.LFD.2.11.1504111340170.2449@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	matti.gottlieb@intel.com
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35063 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755928AbbKDQT4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2015 11:19:56 -0500
In-Reply-To: <alpine.LFD.2.11.1504111340170.2449@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-04-11 at 13:59 +0300, Julian Anastasov wrote:
>=C2=A0
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0May be only arptable_=
filter can help here to
> protect ARP?
>=20

=46inally reviving an ancient thread ...

I checked, butI don't see a way to match tip=3D=3Dsip. You can match on
each, but not against each other.

johannes
