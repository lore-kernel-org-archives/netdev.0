From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: [PATCH RFC iproute2 0/2] ipxfrm: configuration of SPD hash
Date: Fri,  1 Aug 2014 15:01:08 +0200
Message-ID: <1406898070-15942-1-git-send-email-christophe.gouault@6wind.com>
References: <1406884348-12423-3-git-send-email-christophe.gouault@6wind.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:48650 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754796AbaHANBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 09:01:49 -0400
Received: by mail-wi0-f176.google.com with SMTP id bs8so1334153wib.3
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2014 06:01:46 -0700 (PDT)
In-Reply-To: <1406884348-12423-3-git-send-email-christophe.gouault@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is provided in order to test the kernel patchset
"[net-next v2 0/2] xfrm: scalability enhancements for policy database"
for those who would like to play with these new knobs.

Please note that I will be on vacation starting next week, so I will
not be very reactive to comments during August.

Best Regards,
Christophe
---
 include/linux/xfrm.h |   7 +++++
 ip/xfrm_policy.c     | 106
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 109 insertions(+), 4 deletions(-)
