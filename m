From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH net-next 0/3] pktgen: small cleanups
Date: Fri, 21 Feb 2014 21:38:33 +0100
Message-ID: <1393015116-7488-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:39783 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456AbaBUUit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 15:38:49 -0500
Received: by mail-bk0-f51.google.com with SMTP id w10so1229214bkz.10
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 12:38:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series is just a set of small cleanups of pktgen code and
documentation.

Please apply!

Mathias Krause (3):
  pktgen: fix out-of-bounds access in pgctrl_write()
  pktgen: simplify error handling in pgctrl_write()
  pktgen: document all supported flags

 Documentation/networking/pktgen.txt |   24 +++++++++++++++++++-----
 net/core/pktgen.c                   |   32 +++++++++++++++++---------------
 2 files changed, 36 insertions(+), 20 deletions(-)

-- 
1.7.10.4
