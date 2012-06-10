From: "Michael D. Berger" <m_d_berger_1900@yahoo.com>
Subject: tcp/ip server timeout
Date: Sun, 10 Jun 2012 22:32:23 +0000 (UTC)
Message-ID: <jr379n$17r$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:43138 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752778Ab2FJWco (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jun 2012 18:32:44 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1SdqgV-0004IZ-JG
	for netdev@vger.kernel.org; Mon, 11 Jun 2012 00:32:35 +0200
Received: from static-71-246-219-24.washdc.fios.verizon.net ([71.246.219.24])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 00:32:35 +0200
Received: from m_d_berger_1900 by static-71-246-219-24.washdc.fios.verizon.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 00:32:35 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using Linux, Fedora 16.
Is there a way to have a tcp/ip server socket signal or
disconnect when there has been no traffic in either
direction for, say, 5 minutes?

Thanks for your help,
Mike.
