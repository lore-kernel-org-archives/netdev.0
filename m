From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: net-next and IPv6
Date: Wed, 18 Jul 2012 06:58:33 +0200
Message-ID: <1342587513.2626.1518.camel@edumazet-glaptop>
References: <20120717.061418.1893307699868826531.davem@davemloft.net>
	 <20120717.110314.1984735460095688066.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:50674 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565Ab2GRE6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 00:58:37 -0400
Received: by vbbff1 with SMTP id ff1so815783vbb.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 21:58:36 -0700 (PDT)
In-Reply-To: <20120717.110314.1984735460095688066.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


IPv6 doesnt work anymore for me, at least TCP doesnt work

ssh ::1

ping6 is ok

tcpdump shows garbled source IP and ip-proto
