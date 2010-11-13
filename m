From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] pull linux-2.6 into net-next-2.6 ?
Date: Sat, 13 Nov 2010 09:21:18 +0100
Message-ID: <1289636478.2743.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49943 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738Ab0KMIVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Nov 2010 03:21:25 -0500
Received: by wwb29 with SMTP id 29so89654wwb.1
        for <netdev@vger.kernel.org>; Sat, 13 Nov 2010 00:21:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

Andrew pushed to Linus the patch introducing atomic_inc_not_zero_hint()

(commit 3f9d35b9514da675)

Would it be possible to get it in net-next-2.6 so that I can start using
it in network stack ?

Thanks !


