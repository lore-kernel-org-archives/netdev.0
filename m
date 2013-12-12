From: Stefan Raspl <raspl@linux.vnet.ibm.com>
Subject: Re: [PATCH ethtool 0/3] Display adjacent switch port's attributes
Date: Thu, 12 Dec 2013 10:24:57 +0100
Message-ID: <52A980E9.6030901@linux.vnet.ibm.com>
References: <20131209081140.196136547@linux.vnet.ibm.com>
Reply-To: raspl@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Frank Blaschka <blaschka@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-s390 <linux-s390@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp18.uk.ibm.com ([195.75.94.114]:59248 "EHLO
	e06smtp18.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408Ab3LLJZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 04:25:04 -0500
Received: from /spool/local
	by e06smtp18.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raspl@linux.vnet.ibm.com>;
	Thu, 12 Dec 2013 09:25:02 -0000
In-Reply-To: <20131209081140.196136547@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 09.12.2013 09:11, schrieb raspl@linux.vnet.ibm.com:
> This patch series adds a new option to ethtool to display the adjacen=
t switch
> port's attributes, as perceived by the NIC, e.g. through respective L=
LDP
> message exchanges.
> A patch for the qeth device driver provides a sample exploiter for th=
e new
> functionality.
>=20
> Best regards,
> Stefan Raspl
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

Please ignore this stray patch series - the one posted 12/12 is the
real thing.

Regards
Stefan Raspl


--=20
Linux on System z & Virtualization Development
IBM Deutschland Research & Development GmbH
Vorsitzender des Aufsichtsrats: Martina Koederitz
Gesch=E4ftsf=FChrer: Dirk Wittkopp
Sitz der Gesellschaft: B=F6blingen
Registergericht: Amtsgericht Stuttgart, HRB 243294
