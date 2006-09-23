From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/3] bonding: Validate probe replies in ARP monitor
Date: Fri, 22 Sep 2006 20:12:21 -0400
Message-ID: <45147BE5.2070303@pobox.com>
References: <200609212246.k8LMkiZt031759@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:20696 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964952AbWIWAMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 20:12:25 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200609212246.k8LMkiZt031759@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ACK patches 1-3, but does not apply to #upstream.  Also, it adds 
trailing whitespace.

Applying 'bonding: Validate probe replies in ARP monitor'

Adds trailing whitespace.
.dotest/patch:42:
Adds trailing whitespace.
.dotest/patch:46:
error: patch failed: drivers/net/bonding/bond_main.c:1785
error: drivers/net/bonding/bond_main.c: patch does not apply
error: patch failed: drivers/net/bonding/bonding.h:151
error: drivers/net/bonding/bonding.h: patch does not apply
error: patch failed: include/linux/if.h:60
error: include/linux/if.h: patch does not apply

