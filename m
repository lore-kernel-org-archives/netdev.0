From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [PATCH net-next-2.6] bonding: propogate vlan_features to	bonding
 master
Date: Thu, 23 Jul 2009 10:24:25 +0300
Message-ID: <4A681029.4070600@voltaire.com>
References: <24949.1240530461@death.nxdomain.ibm.com>	<4A2CDB16.9030000@Voltaire.com> <4A642600.2010501@voltaire.com>	<3463.1248298460@death.nxdomain.ibm.com> <4A67FD4C.4080407@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:49408 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752838AbZGWHYe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2009 03:24:34 -0400
In-Reply-To: <4A67FD4C.4080407@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Jay Vosburgh a =E9crit :
>> Propogate the vlan_features of the slave devices to the bonding mast=
er device, using the same logic as for regular features.
> Seems pretty cool, but I could not test it on my dev machine, since t=
g3 and bnx2 drivers dont advertize yet vlan_features
The bnx2x maintainer posted yesterday a patch that does so, I assume a=20
similar patch could work for at least one of tg3 or bnx2. I copied both=
=20
maintainers on this email, in  the hope they can come up with a patch.

Or.

