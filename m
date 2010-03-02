From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 00/12] IPv6 addrconf changes
Date: Tue, 02 Mar 2010 15:32:43 -0800
Message-ID: <20100302233243.259794027@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58923 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754907Ab0CBXqk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 18:46:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set includes a mixed bag of changes all related to
IPv6 address configuration:  bugfixes (1-3,8), changes to use
list interface (4-5,8), RCU (6), cosmetic cleanups (9-10,12) and
minor improvments (7,11).

-- 

