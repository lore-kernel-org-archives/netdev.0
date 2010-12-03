From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 0/2] bonding: add the debugfs interface to see RLB hash table
Date: Fri, 03 Dec 2010 11:51:47 +0900
Message-ID: <4CF85B43.2030407@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:50979 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758396Ab0LCCwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 21:52:17 -0500
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB32pm6g014527
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Fri, 3 Dec 2010 11:52:15 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D040A45DE65
	for <netdev@vger.kernel.org>; Fri,  3 Dec 2010 11:52:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B51F045DE64
	for <netdev@vger.kernel.org>; Fri,  3 Dec 2010 11:52:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A5D901DB8038
	for <netdev@vger.kernel.org>; Fri,  3 Dec 2010 11:52:14 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 69509E08002
	for <netdev@vger.kernel.org>; Fri,  3 Dec 2010 11:52:14 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset provides the debugfs facility to the bonding driver and
the interface to see RLB hashtable in it.

 *[PATCH 1/2] bonding: add the debugfs facility to the bonding driver
 *[PATCH 2/2] bonding: add the debugfs interface to see RLB hash table

Best regards,
Taku Izumi

