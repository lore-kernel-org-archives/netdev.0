From: Yuki Machida <machida.yuki@jp.fujitsu.com>
Subject: Backport Security Fix for CVE-2015-8787 to v4.1
Date: Thu, 7 Apr 2016 15:40:30 +0900
Message-ID: <570600DE.2030001@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kamatam@amazon.com, pablo@netfilter.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym03.jp.fujitsu.com ([211.128.242.42]:63583 "EHLO
	mgwym03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbcDGGkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 02:40:36 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 1BBD1AC00F3
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2016 15:40:31 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

I conformed that a patch of CVE-2015-8787 not applied at v4.1.21.
Could you please apply a patch for 4.1-stable ?

CVE-2015-8787
Upstream commit 94f9cd81436c85d8c3a318ba92e236ede73752fc

Regards,
Yuki Machida
