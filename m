From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] phonet: sparse annotations of protocol, remove forward declaration
Date: Fri, 7 Nov 2008 10:41:41 +0200
Message-ID: <200811071041.41787.remi.denis-courmont@nokia.com>
References: <1226022793.5482.1.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-netdev" <netdev@vger.kernel.org>
To: "ext Harvey Harrison" <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:38945 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397AbYKGIlr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 03:41:47 -0500
In-Reply-To: <1226022793.5482.1.camel@brick>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 07 November 2008 03:53:13 ext Harvey Harrison, you wrote:
> net/phonet/af_phonet.c:38:36: error: marked inline, but without a
> definition
> net/phonet/pep-gprs.c:63:10: warning: incorrect type in return=20
> expression (different base types)
> net/phonet/pep-gprs.c:63:10:    expected int
> net/phonet/pep-gprs.c:63:10:    got restricted __be16 [usertype]
> <noident>=20
> net/phonet/pep-gprs.c:65:10: warning: incorrect type in return
> expression=20
> (different base types)
> net/phonet/pep-gprs.c:65:10:    expected int=20
> net/phonet/pep-gprs.c:65:10:    got restricted __be16 [usertype]
> <noident>=20
> net/phonet/pep-gprs.c:124:16: warning: incorrect type in assignment
> (different base types)
> net/phonet/pep-gprs.c:124:16:    expected restricted=20
> __be16 [usertype] protocol
> net/phonet/pep-gprs.c:124:16:    got unsigned short [unsigned]
> [usertype] protocol=20

Thanks. May I ask where the documentation to run these checks is?

--=20
R=C3=A9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
