From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [net-next 06/10] xscale: Move the Intel XScale IXP drivers
Date: Sun, 14 Aug 2011 22:25:22 +0200
Message-ID: <m3mxfb68r1.fsf@intrepid.localdomain>
References: <1313105998-2859-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1313105998-2859-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, Lennert Buytenhek <kernel@wantstofly.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from inx.pm.waw.pl ([195.116.170.130]:57979 "EHLO inx.pm.waw.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752062Ab1HNUZZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2011 16:25:25 -0400
In-Reply-To: <1313105998-2859-7-git-send-email-jeffrey.t.kirsher@intel.com>
	(Jeff Kirsher's message of "Thu, 11 Aug 2011 16:39:54 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher <jeffrey.t.kirsher@intel.com> writes:

> Move the Intel XScale IXP drivers into drivers/net/ethernet/xscale/
> and make the necessary Kconfig and Makefile changes.

>  rename drivers/net/{arm =3D> ethernet/xscale}/ixp4xx_eth.c (100%)

To be honest I don't care if the driver is in the old or new dir.

If this changes anything:

Acked-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
--=20
Krzysztof Halasa
