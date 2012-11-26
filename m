From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next 0/2] tun: trivial fixes.
Date: Mon, 26 Nov 2012 10:07:39 +0200
Message-ID: <1353917261-2974-1-git-send-email-ramirose@gmail.com>
Cc: maxk@qti.qualcomm.com, netdev@vger.kernel.org,
	Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:56810 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754206Ab2KZIId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 03:08:33 -0500
Received: by mail-we0-f174.google.com with SMTP id d7so3309528wer.19
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2012 00:08:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches contain trivial fixes to the tun driver.
  First patch fixes 4 typos.
  Second patch puts the correct method name in a debug message in tun_do_read().

Rami Rosen (2):
  [PATCH net-next 1/2] vtun: fix typos.
  [PATCH net-next 2/2] tun: put correct method name in a debug message.

 drivers/net/tun.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

-- 
1.7.11.7
