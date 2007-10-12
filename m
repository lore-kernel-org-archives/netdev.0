From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 04/12] Fix up various problems in netbug script.
Date: Fri, 12 Oct 2007 10:14:56 -0700
Message-ID: <20071012101456.6d092f74@freepuppy.rosehill>
References: <1192179407-22461-1-git-send-email-andreas@fatal.se>
	<1192179407-22461-2-git-send-email-andreas@fatal.se>
	<1192179407-22461-3-git-send-email-andreas@fatal.se>
	<1192179407-22461-4-git-send-email-andreas@fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Javier =?UTF-8?B?RmVybsOhbmRlei1TYW5ndWlubyBQ?=
	 =?UTF-8?B?ZcOxYQ==?= <jfs@computer.org>,
	Andreas Henriksson <andreas@fatal.se>
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49471 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761035AbXJLRQA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 13:16:00 -0400
In-Reply-To: <1192179407-22461-4-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Oct 2007 10:56:39 +0200
Andreas Henriksson <andreas@fatal.se> wrote:

> From: Javier Fern=C3=83=C2=A1ndez-Sanguino Pe=C3=83=C2=B1a <jfs@compu=
ter.org>
>=20
> Fix race conditions and temporary file symlink attacks.
> See http://bugs.debian.org/289541
>=20
> Additional improvements by Allard Hoeve <allard@byte.nl> and others.
> See http://bugs.debian.org/313540, http://bugs.debian.org/313541,
> and http://bugs.debian.org/313544.
>=20
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>


Does anyone ever use this script? Maybe it should just be pulled?
