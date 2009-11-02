From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Connection tracking and vlan
Date: Mon, 02 Nov 2009 17:41:14 +0100
Message-ID: <4AEF0BAA.7050800@gmail.com>
References: <20091030152054.GA7936@gondor.apana.org.au>	 <4AEB06E6.6020206@gmail.com>	 <fb7befa20910301220y53e43608u3b37de17661feb4e@mail.gmail.com>	 <m1639wmq1f.fsf@fess.ebiederm.org> <4AEB75DD.8050204@candelatech.com> <fb7befa20911020814q2c4bcd1bj7e2b5a4c17ba0f89@mail.gmail.com> <4AEF09E7.2010004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adayadil Thomas <adayadil.thomas@gmail.com>,
	Ben Greear <greearb@candelatech.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37562 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755873AbZKBQlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 11:41:20 -0500
In-Reply-To: <4AEF09E7.2010004@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
>=20
> But it would be preferrable if we could do this using network
> namespaces somehow.

eg eth0.100 and eth0.101 on namespace 1,  eth0.200 and eth0.201 on name=
space 2 ?

Can we do that with current kernel ? (different vlans on an unique phys=
ical device)
