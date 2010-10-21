From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 0/2] cxgb4 updates
Date: Thu, 21 Oct 2010 14:29:54 -0700
Message-ID: <1287696596-15175-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23965 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329Ab0JUV35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 17:29:57 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o9LLTuk3029214
	for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 14:29:56 -0700
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id o9LLTuUP015442
	for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 14:29:56 -0700
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id o9LLTuAO015441
	for netdev@vger.kernel.org; Thu, 21 Oct 2010 14:29:56 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here are two patches for cxgb4.  The first fixes a crash triggered by
e6484930d7c73d324bccda7d43d131088da697b9.  The second updates the driver
to utilize the newer VLAN infrastructure.  If it's too late for the latter
let me know and I'll resend it when net-next reopens.
