From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 0/5] cxgb4 updates
Date: Sun, 11 Jul 2010 15:01:14 -0700
Message-ID: <1278885679-3738-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27833 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754839Ab0GKWBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 18:01:20 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o6BM1JCj021621
	for <netdev@vger.kernel.org>; Sun, 11 Jul 2010 15:01:19 -0700
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id o6BM1Jgs003812
	for <netdev@vger.kernel.org>; Sun, 11 Jul 2010 15:01:19 -0700
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id o6BM1JEi003811
	for netdev@vger.kernel.org; Sun, 11 Jul 2010 15:01:19 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Following is a series of 5 cxgb4 patches, all for net-next.  Mainly they
implement the get_rxnfc, get_rxfh_indir, and set_rxfh_indir ethtool ops,
plus a couple of fixes.
