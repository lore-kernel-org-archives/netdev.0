From: sivareddy kallam <k.sivareddy@gmail.com>
Subject: [stmmac] On mtu change, Not able to ping Host
Date: Tue, 18 Jun 2013 11:27:33 +0530
Message-ID: <CAH5_UQm4SKkJ6QX2bRzG=wEneFG6Tdzx53ATF43g8sxQWjd+ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f169.google.com ([209.85.128.169]:42542 "EHLO
	mail-ve0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544Ab3FRF5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 01:57:55 -0400
Received: by mail-ve0-f169.google.com with SMTP id m1so2830843ves.28
        for <netdev@vger.kernel.org>; Mon, 17 Jun 2013 22:57:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,
We are working on ARM based SoC and using STMMAC Ethernet driver.
In our scenario, we are setting MTU size as more than Ethernet frame size.

Scenario:
1) Setting MTU for Host side, Target side(ARM based SoC) as 5000 bytes.
2) pinging host with packet size 3000, it is fail to ping host.
3) ping host with packet size less than 1586, it is able to ping host

Can you please guide me on this issue?

Thank you.
Siva
