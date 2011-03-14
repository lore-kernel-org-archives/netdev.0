From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/7] TCP CUBIC Hystart fixes
Date: Mon, 14 Mar 2011 10:52:11 -0700
Message-ID: <20110314175211.788224699@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58239 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757033Ab1CNSCD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 14:02:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the merge of my patches and recent update Sangtae.
It addresses the problems reported by Lucas Nussbaum that Hystart causes
poor startup performance over links with lots of buffering.


