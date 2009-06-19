From: Radha Mohan <radhamohan_ch@yahoo.com>
Subject: can we reuse an skb
Date: Fri, 19 Jun 2009 12:16:56 +0530 (IST)
Message-ID: <962874.62146.qm@web94813.mail.in2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from n8-vm0.bullet.mail.in.yahoo.com ([202.86.4.189]:45053 "HELO
	n8-vm0.bullet.mail.in.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752552AbZFSGrG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2009 02:47:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

For an ethernet driver, we need to allocate some pool of SKBs for receiving packets. Is there any way we can reuse the same SKBs without the need to re-allocate in atomic every time one has been used up for netif_rx(). 

Any pointers will be helpful.

-- Mohan


      ICC World Twenty20 England &#39;09 exclusively on YAHOO! CRICKET http://cricket.yahoo.com

