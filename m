From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/8] sky2: driver update
Date: Thu, 06 Aug 2009 09:12:13 -0700
Message-ID: <20090806161213.148382653@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38262 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753275AbZHFQok (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 12:44:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This undoes the prematurely committed sky2 transmit logic changes
and applies Mike's later changes.
Here is a corrected patch stream please apply this to 2.6.31-rc5

-- 

