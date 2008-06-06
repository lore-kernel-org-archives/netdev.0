From: frank.blaschka@de.ibm.com
Subject: [patch 0/5] s390: qeth fixes for 2.6.26
Date: Fri, 06 Jun 2008 12:37:43 +0200
Message-ID: <20080606103743.638691000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:50443 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272AbYFFKia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 06:38:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

I hope these are the final qeth fixes for 2.6.26

shortlog:
Frank Blaschka (3)
qeth: layer 3 Oops in ip event handler
qeth: reduce number of kernel messages
qeth: start dev queue after tx drop error

Cornelia Huck (1)
qeth: Use ccw_device_get_id().

Peter Tiedemann (1)
qeth: Prepare-function to call s390dbf was wrong

Thanks,
        Frank

-- 
