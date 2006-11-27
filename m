From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Cbe-oss-dev] [RFC][PATCH] spidernet: enable fiber autonegotiation
Date: Mon, 27 Nov 2006 17:05:35 +0100
Message-ID: <200611271705.36022.arnd@arndb.de>
References: <200611271547.07433.jens@de.ibm.com> <200611271605.12784.arnd@arndb.de> <200611271646.32153.Jens.Osterkamp@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:38645 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1757065AbWK0QGn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Nov 2006 11:06:43 -0500
To: Jens Osterkamp <Jens.Osterkamp@gmx.de>
In-Reply-To: <200611271646.32153.Jens.Osterkamp@gmx.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 27 November 2006 16:46, Jens Osterkamp wrote:
> Thanks for pointing me to this, I must have overlooked it. Some of it seems 
> only applicable to the Celleb copper interface, but some of it is quite 
> usable for us too.
> 
> Is it already queued upstream ?

No, I'm currently waiting for an updated series for Celleb, ported to
the latest kernel. The spidernet patch from this series has not yet
been submitted to netdev or jgarzik, AFAIK.

	Arnd <><
