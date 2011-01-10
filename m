From: MK <stardust496@gmail.com>
Subject: what are txqueuelen and nic ring parameters exactly?
Date: Mon, 10 Jan 2011 00:38:16 -0500
Message-ID: <AANLkTi=_hbmvgO9wrX6sg7Q=Wh+iVaqGdga08M-ypqae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51412 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891Ab1AJFiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 00:38:17 -0500
Received: by iwn9 with SMTP id 9so18880638iwn.19
        for <netdev@vger.kernel.org>; Sun, 09 Jan 2011 21:38:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I often come across two variables that can be tuned for networking -

1) txqueuelen (via ifconfig )
2) NIC ring parameters for tx and rx (via ethtool)

Can someone please tell me where these queues are exactly? Are both
the same (seems not since their current values are different on my
computer) . Is txqueuelen somehow part of the linux networking
subsystem whereas the other is purely a h/w device construct?

Thanks a lot!
