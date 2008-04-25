From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] /sbin/ifcfg assumes ip, arping and rdisc are in $PATH
Date: Fri, 25 Apr 2008 03:14:18 -0700 (PDT)
Message-ID: <20080425.031418.193687415.davem@davemloft.net>
References: <4811ACE6.7020908@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: mmaslano@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46481
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753825AbYDYKOS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 06:14:18 -0400
In-Reply-To: <4811ACE6.7020908@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Marcela Maslanova <mmaslano@redhat.com>
Date: Fri, 25 Apr 2008 12:05:26 +0200

> Patch from Ville Skytt=E4.
> /sbin/ifcfg assumes that ip, arping, and rdisc are in $PATH which is =
not the
> case eg. after "sudo -s" from a non-root user. =20

You patch assumes 'ip' was installed in /sbin :-)
