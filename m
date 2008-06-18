From: "Jean-Philippe RAMES" <jprames@ags-backup.com>
Subject: RE: Traffic Control - Burst 4096Mb ?!
Date: Wed, 18 Jun 2008 13:08:51 +0200
Message-ID: <BD53B6560CD66B4AA230BBB09CD2C8F346DB97@ags-exch.ags-intranet.net>
References: <BD53B6560CD66B4AA230BBB09CD2C8F3244275@ags-exch.ags-intranet.net> <BD53B6560CD66B4AA230BBB09CD2C8F346DB91@ags-exch.ags-intranet.net> <4858E2CE.5020605@trash.net> <BD53B6560CD66B4AA230BBB09CD2C8F346DB94@ags-exch.ags-intranet.net> <4858E43B.2080008@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.ags-backup.com ([195.101.79.129]:28147 "EHLO
	exchange.ags-backup.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752363AbYFRLJd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 07:09:33 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4858E43B.2080008@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks I going to try.


-----Message d'origine-----
De=A0: Patrick McHardy [mailto:kaber@trash.net]=20
Envoy=E9=A0: mercredi 18 juin 2008 12:32
=C0=A0: Jean-Philippe RAMES
Cc=A0: netdev@vger.kernel.org
Objet=A0: Re: Traffic Control - Burst 4096Mb ?!

Jean-Philippe RAMES wrote:
> iproute2-ss070313

That version is known to have integer overflows. Any more
revent version should fix it.
