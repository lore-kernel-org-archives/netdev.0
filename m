From: Simon Horman <horms@verge.net.au>
Subject: [patch 0/3] IPVS: Use CTL_UNNUMBERED
Date: Wed, 14 Nov 2007 10:06:15 -0800
Message-ID: <20071114180615.251592665@natsuko.shinjuku.tokyo.vergenet.net>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:36757 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757189AbXKNSKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 13:10:16 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this series of three patches, the first of which is by
Christian Borntraeger, switches IPVS over to use CTL_UNNUMBERED,
removing a lot of unused cruft.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

