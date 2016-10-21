From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: network packet kernel rate limit
Date: Fri, 21 Oct 2016 06:17:06 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF5CB42C@cnshjmbx02>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:53847 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750856AbcJUGcf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 02:32:35 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

User space application require linux kernel to do rate limit to some type of Ethernet packet(ARP, ICMP, TCP, for example 1000 packet/s) when system run under Ethernet packet flooding test.
Do you know if kernel already exist a feature to implement this requirement?

Thanks
