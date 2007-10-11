From: Al Boldi <a1426z@gawab.com>
Subject: [RFD] iptables:  mangle table obsoletes filter table
Date: Fri, 12 Oct 2007 00:31:42 +0300
Message-ID: <200710120031.42805.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, linux-kernel@vger.kernel.org
To: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [212.12.190.29] ([212.12.190.29]:33921 "EHLO raad.intranet"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754905AbXJKVcX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 17:32:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the existence of the mangle table, how useful is the filter table?

Other than requiring the REJECT target to be ported to the mangle table, is 
the filter table faster than the mangle table?

If not, then shouldn't the filter table be obsoleted to avoid confusion?


Thanks!

--
Al

