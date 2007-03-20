From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: ping6 to own link-local address
Date: Tue, 20 Mar 2007 10:19:11 +0100 (CET)
Message-ID: <20070320.101911.50437044.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: CHINEN@jp.ibm.com, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35018 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932440AbXCTJSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 05:18:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Recent 2.6.21-git kernels do not respond to ping6 queries
to our own (local) link-local address.  Now bisecting...

--yoshfuji
