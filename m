From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: Re: [PATCH v2 0/3] bonding: add the debugfs interface to see RLB
 hash table
Date: Fri, 10 Dec 2010 10:24:48 +0900
Message-ID: <4D018160.1070604@jp.fujitsu.com>
References: <4CF89A00.8030902@jp.fujitsu.com> <3778.1291840382@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:45629 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757729Ab0LJBY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 20:24:56 -0500
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBA1OsCb016726
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Fri, 10 Dec 2010 10:24:55 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B99B345DE56
	for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 10:24:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9277845DE5B
	for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 10:24:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 831901DB8046
	for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 10:24:54 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C881E08002
	for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 10:24:54 +0900 (JST)
In-Reply-To: <3778.1291840382@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay,

 I updated the patch 1/3. The problem seems to be fixed.
 The problem is not reproduced at least in my test by applying my new patch.
 Could you test again?

Best regards,
Taku Izumi


