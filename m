From: "Natalie Protasevich" <protasnb@gmail.com>
Subject: [BUG] Kernel Bugzilla: networking bugs
Date: Thu, 13 Dec 2007 21:19:40 -0800
Message-ID: <32209efe0712132119v5020443fw13fed1b0b4bd415b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:17783 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521AbXLNFTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 00:19:42 -0500
Received: by nf-out-0910.google.com with SMTP id g13so801381nfb.21
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 21:19:41 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
Here are few networking bugs from bugzilla.kernel.org. Could someone
take a look please?
Thanks!

(net forcedeth) frequent network ups and downs
http://bugzilla.kernel.org/show_bug.cgi?id=9200
Kernel: 2.6.23
00:07.0 Bridge: nVidia Corporation MCP61 Ethernet (rev a2)

rtl8187 very unreliable (wireless)
http://bugzilla.kernel.org/show_bug.cgi?id=9143
Kernel: 2.6.23
John Linville started looking in it

Unable to associate rt25xx USB key with a WPA AP (wireless)
http://bugzilla.kernel.org/show_bug.cgi?id=9388
Kernel: 2.6.24-rc2
D-Link DWL-G122 Wifi 11b/g USB key
