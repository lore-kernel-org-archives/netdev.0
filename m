From: Hasso Tepper <hasso@estpak.ee>
Subject: No interfaces under /proc/sys/net/ipv4/conf/
Date: Wed, 21 Jun 2006 16:31:39 +0300
Message-ID: <200606211631.39656.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from test.estpak.ee ([194.126.115.47]:17115 "EHLO
	localhost.localdomain") by vger.kernel.org with ESMTP
	id S932142AbWFUNbn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 09:31:43 -0400
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by localhost.localdomain (Postfix) with ESMTP id 124BA10F7A
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 16:31:41 +0300 (EEST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After upgrade to 2.6.16.20 from 2.6.11 I discovered that no dynamic 
interfaces (vlans, tunnels) appear under /proc/sys/net/ipv4/conf/.
/proc/sys/net/ipv6/conf/ is OK.

Bug? Or feature?


with my best wishes,

-- 
Hasso Tepper
