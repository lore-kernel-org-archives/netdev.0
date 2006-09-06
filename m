From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/9] s390: minor s390 network driver fixes
Date: Wed, 06 Sep 2006 11:15:27 -0400
Message-ID: <44FEE60F.5090207@pobox.com>
References: <200609061705.09801.fpavlic@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev Mailinglist <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:7899 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751368AbWIFPP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 11:15:29 -0400
To: fpavlic@de.ibm.com
In-Reply-To: <200609061705.09801.fpavlic@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ACK patches 1-9, but patch #1 failed to apply to netdev-2.6.git#upstream:

[jgarzik@pretzel netdev-2.6]$ git-applymbox /g/tmp/mbox ~/info/signoff.txt
9 patch(es) to process.

Applying 's390: minor s390 network driver fixes'

error: patch failed: drivers/s390/net/ctcmain.c:1714
error: drivers/s390/net/ctcmain.c: patch does not apply
error: patch failed: drivers/s390/net/lcs.c:670
error: drivers/s390/net/lcs.c: patch does not apply


