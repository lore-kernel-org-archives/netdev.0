From: Stefan BOSAK <stefan.bosak@gmail.com>
Subject: Access to repo on git.linux-ipv6.org
Date: Wed, 08 Jun 2011 23:31:26 +0200
Message-ID: <4DEFEA2E.3010602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33482 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090Ab1FHVbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 17:31:32 -0400
Received: by wwa36 with SMTP id 36so1018364wwa.1
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2011 14:31:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

I would like to ask you how to access:
git://git.linux-ipv6.org/gitroot/iputils.git

IPv4 git service not running:
Nmap scan report for git.linux-ipv6.org (203.178.142.218)
Host is up (0.29s latency).
rDNS record for 203.178.142.218: nezu.linux-ipv6.org
PORT     STATE  SERVICE
9418/tcp closed git

IPv6 git service running, but what git options should i used to clone it:
Nmap scan report for git.linux-ipv6.org (2001:200:0:1c01:20f:1fff:fe67:32e9)
Host is up (0.30s latency).
PORT     STATE SERVICE
9418/tcp open  git

Thank you for your help.
