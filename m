From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net:mv88e6xxx: use g2 interrupt for 6097
 chip
Date: Tue, 03 Jan 2017 11:18:22 -0500 (EST)
Message-ID: <20170103.111822.1574940430319204745.davem@davemloft.net>
References: <1483456720-9929-1-git-send-email-volodymyr.bendiuga@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
To: volodymyr.bendiuga@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39548 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759527AbdACQS1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 11:18:27 -0500
In-Reply-To: <1483456720-9929-1-git-send-email-volodymyr.bendiuga@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Date: Tue,  3 Jan 2017 16:18:40 +0100

> + 	 MV88E6XXX_FLAG_G2_INT |	\

Space before TAB character is still there on this line, right after
the "+".
