From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Documentation error for checksum offload check ?
Date: Fri, 07 Apr 2017 10:23:06 +1000
Message-ID: <1491524586.4166.144.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:34312 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755449AbdDGAXN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 20:23:13 -0400
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
        by gate.crashing.org (8.14.1/8.13.8) with ESMTP id v370N7XO027563
        for <netdev@vger.kernel.org>; Thu, 6 Apr 2017 19:23:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed in both Documentation/networking/checksum-offload.txt
and include/linux/skbuff.h reference to helpers

skb_csum_off_chk*

Now, I can't find anything like that with grep ... :-)

Am I missing something ?

Cheers,
Ben.
