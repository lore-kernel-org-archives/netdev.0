From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] Phonet: small pipe protocol fixes
Date: Fri, 25 Feb 2011 11:20:55 -0800 (PST)
Message-ID: <20110225.112055.260096987.davem@davemloft.net>
References: <201102251113.41620.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ofono@ofono.org
To: netdev@vger.kernel.org, remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55843
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756303Ab1BYTUS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 14:20:18 -0500
In-Reply-To: <201102251113.41620.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Fri, 25 Feb 2011 11:13:41 +0200

> This patch series cleans up and fixes a number of small bits in the
> Phonet pipe code, especially the experimental pipe controller. Once
> this small bits are sorted out, I will try to fix the controller
> protocol implementation proper so that we do not need the
> compile-time (experimental) flag anymore.

All applied thanks.

If you want to start using GIT to push phonet changes to me, frankly I
would welcome that :-)
