From: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Subject: Re: [Cbe-oss-dev] [RFC][PATCH] spidernet: enable fiber autonegotiation
Date: Mon, 27 Nov 2006 16:46:32 +0100
Message-ID: <200611271646.32153.Jens.Osterkamp@gmx.de>
References: <200611271547.07433.jens@de.ibm.com> <200611271605.12784.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:29325 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S1758332AbWK0Pqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 10:46:37 -0500
To: Arnd Bergmann <arnd@arndb.de>
In-Reply-To: <200611271605.12784.arnd@arndb.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> There was a patch from Ishizaki Kou recently, to set up autonegotiate
> and other things, see http://patchwork.ozlabs.org/linuxppc/patch?id=8121 .
>
> Are you sure that you don't need any of those changes as well?

Thanks for pointing me to this, I must have overlooked it. Some of it seems 
only applicable to the Celleb copper interface, but some of it is quite 
usable for us too.

Is it already queued upstream ?

Jens
