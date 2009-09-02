From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/5] More const ops cleanups
Date: Tue, 01 Sep 2009 22:25:00 -0700
Message-ID: <20090902052500.808557262@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46823 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755803AbZIBFhG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 01:37:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many places were not using const when defining/using structures
that only contain initialized values.

-- 

