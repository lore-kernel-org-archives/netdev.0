From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/3] net: sysfs: documentation updates
Date: Fri, 23 May 2014 16:35:39 -0700
Message-ID: <1400888142-5963-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, therbert@google.com, edumazet@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:50779 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbaEWXfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 19:35:52 -0400
Received: by mail-pa0-f47.google.com with SMTP id lf10so4710905pab.6
        for <netdev@vger.kernel.org>; Fri, 23 May 2014 16:35:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch set contains some updates to the sysfs Documentation for the
sysfs net class.

Thanks

Florian Fainelli (3):
  net: sysfs: add missing phys_port_id documentation
  net: sysfs: add documentation entries for /sys/class/<iface>/queues
  net: sysfs: document /sys/class/net/statistics/*

 Documentation/ABI/testing/sysfs-class-net          |   8 +
 Documentation/ABI/testing/sysfs-class-net-queues   |  79 ++++++++
 .../ABI/testing/sysfs-class-net-statistics         | 202 +++++++++++++++++++++
 3 files changed, 289 insertions(+)
 create mode 100644 Documentation/ABI/testing/sysfs-class-net-queues
 create mode 100644 Documentation/ABI/testing/sysfs-class-net-statistics

-- 
1.9.1
