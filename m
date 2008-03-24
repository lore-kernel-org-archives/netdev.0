From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 0/3] llc: fixes for net-2.6
Date: Mon, 24 Mar 2008 17:29:17 +0900
Message-ID: <20080324082824.GA19715@tp61p-64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jwestfall@surrealistic.net
To: davem@davemloft.net, acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.245]:50199 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017AbYCXI3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 04:29:24 -0400
Received: by hs-out-0708.google.com with SMTP id 4so2121231hsl.5
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2008 01:29:21 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset does fix some problems of the llc.
It fixes oops which was reported by Jim (http://www.spinics.net/lists/netdev/msg55712.html) and zero source mac address problem.

[PATCH 1/3] [LLC]: skb allocation size for responses
[PATCH 2/3] [LLC]: bogus llc packet length
[PATCH 3/3] [LLC]: zero station mac source address

Dave, Arnaldo, please review and consider applying.

Thanks,
Joonwoo
