From: Hemant-vilas RAMDASI <hemant.ramdasi@stericsson.com>
Subject: RE: [PATCH] Phonet: set the pipe handle using setsockopt
Date: Thu, 10 Nov 2011 10:44:54 +0100
Message-ID: <81C3A93C17462B4BBD7E272753C105791FB090A127@EXDCVYMBSTM005.EQ1STM.local>
References: <1320837653-7471-1-git-send-email-hemant.ramdasi@stericsson.com>
 <6033284.KrP4yu8ukf@hector>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dinesh Kumar SHARMA (STE)" <dinesh.sharma@stericsson.com>
To: =?iso-8859-1?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:35317 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757538Ab1KJJpE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Nov 2011 04:45:04 -0500
In-Reply-To: <6033284.KrP4yu8ukf@hector>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remi,

> -----Original Message-----
> From: R=E9mi Denis-Courmont [mailto:remi.denis-courmont@nokia.com]
> Sent: Wednesday, November 09, 2011 8:31 PM
> To: Hemant-vilas RAMDASI
> Cc: netdev@vger.kernel.org; Dinesh Kumar SHARMA (STE)
> Subject: Re: [PATCH] Phonet: set the pipe handle using setsockopt
>=20
> Inline...
>=20
> Le Mercredi 9 Novembre 2011 16:50:53 ext Hemant Vilas RAMDASI a =E9cr=
it :

[...]

>=20
> It looks like there is no use-case for init-enabled pipes then, right=
?
> How
> about dropping this extra bit of code and assuming connect()ed pipes
> are
> always init-disabled?

VT pipes can still be init-enabled.

Regards,
Hemant=20
