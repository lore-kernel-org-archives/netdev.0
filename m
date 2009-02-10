From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH net-next 0/4] enic: updates
Date: Mon, 09 Feb 2009 16:57:01 -0800
Message-ID: <20090210005505.24315.66810.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:61325 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166AbZBJA5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 19:57:08 -0500
Received: from sj-core-2.cisco.com (sj-core-2.cisco.com [171.71.177.254])
	by sj-dkim-2.cisco.com (8.12.11/8.12.11) with ESMTP id n1A0v6ET012686
	for <netdev@vger.kernel.org>; Mon, 9 Feb 2009 16:57:06 -0800
Received: from palito_client100.nuovasystems.com (savbu-palito-client100.cisco.com [10.193.70.13])
	by sj-core-2.cisco.com (8.13.8/8.13.8) with ESMTP id n1A0v6QO000866
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 00:57:06 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some updates to enic driver:

1: bug fix: return notify intr credits
2: record all bad FCS errs as frame errors
3: bug fix: tx_timeout reset path fix-ups
4: misc stuff

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
