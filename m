From: frank.blaschka@de.ibm.com
Subject: [patch 0/4] s390: net drivers convert to net_device_ops
Date: Fri, 09 Jan 2009 10:01:56 +0100
Message-ID: <20090109090156.422658000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:60964 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753653AbZAIJCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 04:02:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are the remaining net_device_ops patches for s390 net drivers

lcs: convert to net_device_ops
ctcm: convert to net_device_ops
netiucv: convert to net_device_ops
claw: convert to net_device_ops

Thanks,
        Frank

-- 
