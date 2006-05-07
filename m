From: benzi vizman <benziwa@netvision.net.il>
Subject: when to use ip_route_input() and not ip_route_output_key
Date: Sun, 07 May 2006 14:58:39 +0300
Message-ID: <703ef9de19d8.445e0b1f@netvision.net.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxout4.netvision.net.il ([194.90.9.27]:17251 "EHLO
	mxout4.netvision.net.il") by vger.kernel.org with ESMTP
	id S1750757AbWEGL6l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 May 2006 07:58:41 -0400
Received: from netvision.net.il ([192.168.10.8]) by mxout4.netvision.net.il
 (Sun Java System Messaging Server 6.2-4.03 (built Sep 22 2005))
 with ESMTP id <0IYW00FNJ99R1E30@mxout4.netvision.net.il> for
 netdev@vger.kernel.org; Sun, 07 May 2006 14:58:39 +0300 (IDT)
To: netdev@vger.kernel.org
Content-language: he
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

  Can one summerize what's the cases calling each of these routing queries?
What are the differences?

Benzi.

