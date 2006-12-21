From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4][SCTP]: Implement SCTP_FRAGMENT_INTERLEAVE socket
 option.
Date: Wed, 20 Dec 2006 16:08:00 -0800 (PST)
Message-ID: <20061220.160800.30171139.davem@davemloft.net>
References: <1166659257.5722.17.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36099
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161059AbWLUAIB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 19:08:01 -0500
To: sri@us.ibm.com
In-Reply-To: <1166659257.5722.17.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Sridhar Samudrala <sri@us.ibm.com>
Date: Wed, 20 Dec 2006 16:00:57 -0800

> [SCTP]: Implement SCTP_FRAGMENT_INTERLEAVE socket option.
>=20
> This option was introduced in draft-ietf-tsvwg-sctpsocket-13.  It
> prevents head-of-line blocking in the case of one-to-many endpoint.
> Applications enabling this option really must enable SCTP_SNDRCV even=
t
> so that they would know where the data belongs.  Based on an
> earlier patch by Ivan Skytte J=F8rgensen.
>=20
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

The merge window for 2.6.20 features is closed, therefore I cannot
merge this now.  Please resubmit during the 2.6.21 merge window, thank
you.
