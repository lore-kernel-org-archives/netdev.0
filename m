From: Bronek Kozicki <brok@spamcop.net>
Subject: patch 4.8 "net: handle no dst on skb in icmp6_send"
Date: Sun, 8 Jan 2017 21:46:18 +0000
Message-ID: <02a7e2d2-cc1d-1c64-ac9b-7daf8a834b56@spamcop.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>,
        "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from b-painless.mh.aa.net.uk ([81.187.30.52]:47429 "EHLO
        b-painless.mh.aa.net.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933408AbdAHWEx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 17:04:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

any particular reason why this fix 
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=79dc7e3f1cd323be4c81aa1a94faa1b3ed987fb2 
was missed from stable 4.8 line? Apparently the bug being fixed has its 
own https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2016-9919

Thank you for your hard work and best regards


B.
