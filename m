From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG net-next] lost bnx2x
Date: Mon, 19 Sep 2011 06:32:40 +0200
Message-ID: <1316406760.2521.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f170.google.com ([74.125.82.170]:44966 "EHLO
	mail-wy0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801Ab1ISEcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 00:32:47 -0400
Received: by wyg8 with SMTP id 8so8616393wyg.1
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2011 21:32:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With latest net-next, my bnx2x doesnt start

bnx2x: Can't load firmware file bnx2x/bnx2x-e1h-7.0.23.0.fw

But I do have the file in /lib/firmware/bnx2x/bnx2x-e1h-7.0.23.0.fw
