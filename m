From: xeb@mail.ru
Subject: driver for pptp
Date: Sat, 03 Jun 2006 11:06:19 +0400
Message-ID: <E1FmQDD-0005kY-00.xeb-mail-ru@f51.mail.ru>
Reply-To: xeb@mail.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from f51.mail.ru ([194.67.57.86]:16905 "EHLO f51.mail.ru")
	by vger.kernel.org with ESMTP id S932588AbWFCHGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jun 2006 03:06:20 -0400
Received: from mail by f51.mail.ru with local
	id 1FmQDD-0005kY-00
	for netdev@vger.kernel.org; Sat, 03 Jun 2006 11:06:19 +0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.
I have developed the driver for Point-to-Point Tunneling Protocol (PPTP).
This driver works in pair with plugin for pppd.
It is enough to use pppd's plugin for start of the client.
Also there is a server (based on pptpd) which uses this driver.
By results of my testing the speed of transfer has increased on >50% and cpu usage has decreased on >50% in comparison with original pptpd and pptpclient.
I have published the project on http://accel-pptp.sourceforge.net/
There is more then 65 downloads but no any bug report (and no any positive result report).
I think the driver still requires testing.

Hope this driver will go to a kernel tree and will make linux more productive.

