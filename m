From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v2 0/6] skb data accessor cleanups
Date: Fri, 16 Jun 2017 14:29:18 +0200
Message-ID: <20170616122924.3557-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:32936 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751909AbdFPM3b (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Jun 2017 08:29:31 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.89)
        (envelope-from <johannes@sipsolutions.net>)
        id 1dLqNV-00006l-Ox
        for netdev@vger.kernel.org; Fri, 16 Jun 2017 14:29:29 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes from v1:
 * add skb_put_u8() as suggested by Joe and Bjørn

Again build-tested by myself and kbuild bot.

johannes
