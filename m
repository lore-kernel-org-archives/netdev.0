From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Subject: [PATCH 1/7] [DCCP]: Fix typo
Date: Thu, 24 Aug 2006 15:18:36 +1200
Message-ID: <200608241518.37099.ian.mcdonald@jandi.co.nz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:43286 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1030235AbWHXDSs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 23:18:48 -0400
Received: by py-out-1112.google.com with SMTP id n25so508547pyg
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2006 20:18:47 -0700 (PDT)
To: Andrea Bittau <a.bittau@cs.ucl.ac.uk>,
	David Miller <davem@davemloft.net>,
	Arnaldo de Melo <arnaldo.melo@gmail.com>,
	"DCCP (vger)" <dccp@vger.kernel.org>,
	"netdev, " <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes a small typo in net/dccp/libs/packet_history.c

Signed off by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index ad98d6a..6739be1 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -1,5 +1,5 @@
 /*
- *  net/dccp/packet_history.h
+ *  net/dccp/packet_history.c
  *
  *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
  *
