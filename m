From: frank.blaschka@de.ibm.com
Subject: [patch 0/5] [resend]s390: net drivers convert to net_device_ops
Date: Fri, 09 Jan 2009 14:43:55 +0100
Message-ID: <20090109134355.784732000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:37305 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753369AbZAINom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 08:44:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are the remaining (fixed) net_device_ops patches for s390
net drivers

lcs: convert to net_device_ops
ctcm: convert to net_device_ops
netiucv: convert to net_device_ops
claw: convert to net_device_ops
qeth: fix usage of netdev_ops

Thanks,
        Frank

-- 
