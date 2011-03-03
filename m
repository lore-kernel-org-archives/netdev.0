From: Pierre Ynard <linkfanel@yahoo.fr>
Subject: Re: [RFC][PATCH] Export all RA options that we don't handle to
 userspace
Date: Thu, 3 Mar 2011 02:30:57 +0100
Message-ID: <20110303013057.GA12959@via.ecp.fr>
References: <20101212144706.1d2be015@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pierre-list@ossman.eu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:50054 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752442Ab1CCBbG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 20:31:06 -0500
Content-Disposition: inline
In-Reply-To: <20101212144706.1d2be015@mjolnir.ossman.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Second patch that exports everything. If noone objects to this model,
> then merge the two patches and just use the commit message from the
> second one.

I'm a bit wary about that, we don't know what new option might come out
in the future, that we really don't want to forward to userspace. I
suggest we remain conservative here.

Regards,

--=20
Pierre Ynard
"Une =E2me dans un corps, c'est comme un dessin sur une feuille de papi=
er."
