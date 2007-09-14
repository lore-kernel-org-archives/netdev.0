From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Add IP1000A Driver into Kernel (2007/09/12)
Date: Fri, 14 Sep 2007 23:11:08 +0200
Message-ID: <20070914211108.GB22975@electric-eye.fr.zoreil.com>
References: <1189774938.3353.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, akpm@linux-foundation.org, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, s.l-h@gmx.de
To: Jesse Huang <jesse@icplus.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59586 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756661AbXINVOP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 17:14:15 -0400
Content-Disposition: inline
In-Reply-To: <1189774938.3353.1.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Huang <jesse@icplus.com.tw> :
[...]
> Change Logs: Add IP1000A Driver to kernel tree.

It misses the needed Kconfig, Makefile and pci_ids changes
from Stefan Lippers-Hollmann.

-- 
Ueimor
