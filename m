From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH v4 0/2][RFC] iWARP Core Support
Date: Wed, 02 Aug 2006 15:27:47 -0500
Message-ID: <20060802202747.24212.10931.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, openib-general@openib.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-218-104.sw.biz.rr.com ([24.153.218.104]:6109 "EHLO
	dell3.ogc.int") by vger.kernel.org with ESMTP id S932167AbWHBU1t
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 16:27:49 -0400
To: rdreier@cisco.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Roland, 

Here is the iWARP Core Support patchset merged to your latest for-2.6.19
branch.  It has gone through 3 reviews on lklm and netdev a while ago, and
I think its ready to be pulled in.

Steve.

----

This patchset defines the modifications to the Linux infiniband subsystem
to support iWARP devices.  

The patchset consists of 2 patches:

        1 - New iWARP CM implementation.  
        2 - Core changes to support iWARP.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: Steve Wise <swise@opengridcomputing.com>
