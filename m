From: Vlad Yasevich <vyasevich@gmail.com>
Subject: udp v6 early demux?
Date: Tue, 10 Feb 2015 12:14:12 -0500
Message-ID: <54DA3C64.1060309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:42120 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752777AbbBJROR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 12:14:17 -0500
Received: by mail-qg0-f47.google.com with SMTP id q107so12561823qgd.6
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 09:14:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

While testing udpv6 lockless path, I noticed that there is no
support for udpv6 early demux?  Is there a technical reason why,
or was this just something that got forgotten (kind of like
lockeless sendmsg)?

Thanks
-vlad
