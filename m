From: Marcus Better <marcus@better.se>
Subject: Re: [PATCH] bcm43xx-d80211: proper implementation of virtual interface support
Date: Thu, 04 May 2006 21:26:56 +0200
Message-ID: <e3dkfd$pc5$1@sea.gmane.org>
References: <200605012135.00895.mb@bu3sch.de> <20060502132037.059a7cb2@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:46738 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1030302AbWEDT1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 15:27:36 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1FbjTk-0001jR-Bq
	for netdev@vger.kernel.org; Thu, 04 May 2006 21:27:12 +0200
Received: from 67.152.216.81.g-va.siw.siwnet.net ([81.216.152.67])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 04 May 2006 21:27:12 +0200
Received: from marcus by 67.152.216.81.g-va.siw.siwnet.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 04 May 2006 21:27:12 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Jiri Benc wrote:
> This is unnecessary. AFAIK bcm43xx hardware doesn't support more than one
> interface at a time (not counting monitor interfaces as those are somewhat
> special).

I wonder what exactly is causing this limitation? Why isn't it just a matter
of software support?

Marcus

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQFEWlUrXjXn6TzcAQkRAoa6AJ97kI8F7Q42orjNQC6HBIXwj3I/DwCgux18
RBkhEcOFBDtQGEHFq2eMxKU=
=3WoL
-----END PGP SIGNATURE-----

