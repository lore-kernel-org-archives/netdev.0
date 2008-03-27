From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/6 net-2.6.26] [UDP]: udp_proc_register simplification.
Date: Thu, 27 Mar 2008 17:10:41 +0300
Message-ID: <1206627041.2109.15.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:30036 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751386AbYC0OKL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 10:10:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Dave!

Here is a small set of changes to simplify udp_proc_register. It seems
to difficult for me. Let's simplify it a bit.

Regards,
	Den

