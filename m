From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: add new PCI ID
Date: Sat, 27 May 2006 13:39:19 +0200
Message-ID: <20060527113919.GA1883@electric-eye.fr.zoreil.com>
References: <20060525102446.572bb5ca.yoichi_yuasa@tripeaks.co.jp> <4477AFAB.6050405@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:43745 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751464AbWE0Lkh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 May 2006 07:40:37 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <4477AFAB.6050405@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> :
[...]
> applied

$ grep 8129 drivers/net/*.[ch]
[...]
drivers/net/8139too.c:  {0x10ec, 0x8129, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 }

Not a big issue but I would be really surprized that it does trigger
a few PR.

-- 
Ueimor
