From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH 1/1] IEEE80154: Add documentation to the IEEE80154
 netlink and fakehard driver
Date: Fri, 24 Jul 2009 08:31:18 +0000 (UTC)
Message-ID: <h4brgl$q8g$1@ger.gmane.org>
References: <1248281484-3064-1-git-send-email-dsilvers@digital-scurf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:56930 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751445AbZGXIba (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jul 2009 04:31:30 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1MUGBc-0004rV-FE
	for netdev@vger.kernel.org; Fri, 24 Jul 2009 08:31:28 +0000
Received: from iap-pxy-mow1.siemens.ru ([212.248.25.26])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2009 08:31:28 +0000
Received: from dbaryshkov by iap-pxy-mow1.siemens.ru with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2009 08:31:28 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Silverstone wrote:

> This adds some perfunctory documentation comments to the IEEE 802.15.4
> fakehard.c driver (Fake hard MAC) and the nl802154.h (outgoing netlink
> messages) header.
> 
> These comments are not necessarily complete, but they do reference the
> IEEE 802.15.4-2006 document where possible.
> 

Thank you, pulled in. Will push to davem soon.
In future please Cc either one of stack maintainers or linux-zigbee-devel
list.

Thank you!

-- 
With best wishes
Dmitry


