From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/7] bonding: Add 10 Gig support
Date: Wed, 06 Sep 2006 11:17:13 -0400
Message-ID: <44FEE679.6030201@pobox.com>
References: <200609012208.k81M86Zt005275@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:13275 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751348AbWIFPRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 11:17:16 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200609012208.k81M86Zt005275@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ACK patches 1-7, but does not apply:

[jgarzik@pretzel netdev-2.6]$ git-applymbox /g/tmp/mbox ~/info/signoff.txt
7 patch(es) to process.

Applying 'bonding: Add 10 Gig support'

fatal: corrupt patch at line 10

