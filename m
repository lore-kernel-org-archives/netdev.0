From: Pierre Ynard <linkfanel@yahoo.fr>
Subject: Re: [Bugme-new] [Bug 9349] New: RTNLGRP_ND_USEROPT does not report
	ifindex
Date: Tue, 13 Nov 2007 00:44:44 +0100
Message-ID: <20071112234444.GA1581@via.ecp.fr>
References: <20071111115903.90f0fdc0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rdenis@simphalempin.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g19.free.fr ([212.27.42.30]:52295 "EHLO smtp4-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752753AbXKLXpK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 18:45:10 -0500
Content-Disposition: inline
In-Reply-To: <20071111115903.90f0fdc0.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 11 Nov 2007 10:52:41 -0800 (PST) bugme-daemon@bugzilla.kernel.o=
rg wrote:
> The RTNLGRP_ND_USEROPT NetLink message introduced in 2.6.24 does not
> seem to include any information as to which netif the user options
> come from. Considering this is meant to carry data that is heavily
> link-layer involved, this seems like a feature bug. Could an ifindex
> field be added there??

Ok, I am seeing to this.

--=20
Pierre Ynard
=46or hire in Quebec City, Canada, during Fall 2007
"Une =E2me dans un corps, c'est comme un dessin sur une feuille de papi=
er."
