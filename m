From: "Ron Mercer" <ron.mercer@qlogic.com>
Subject: RE: New Qlogic qla3xxx NIC Driver v2.02.00k34 for upstream inclusion
Date: Fri, 23 Jun 2006 14:23:10 -0700
Message-ID: <0BB3E5E7462EEA4295BC02D49691DC071769A2@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-driver@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.qlogic.com ([198.70.193.2]:13758 "EHLO avexch1.qlogic.com")
	by vger.kernel.org with ESMTP id S1752077AbWFWVXK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 17:23:10 -0400
Content-class: urn:content-classes:message
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 9) [minor] "N/A" appears to be an inaccurate value for fw_version in 
> ql_get_drvinfo()

Does anyone know what would be appropriate for this ethtool command?  My
device does not use firmware.  I took the "N/A" idea from e1000 and
skge.




