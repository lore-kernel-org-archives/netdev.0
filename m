From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 0/8] bridge: new security features
Date: Mon, 29 Oct 2012 17:57:31 -0700
Message-ID: <20121030005731.843020405@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:35095 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761774Ab2J3BGO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 21:06:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set implements some new API's and features to allow limiting
reception of Spanning Tree Protocol packets.
