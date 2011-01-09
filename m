From: Chin Shi Hong <cshong87@gmail.com>
Subject: Reset hardware address (MAC address) in c++
Date: Sun, 9 Jan 2011 22:39:13 +0800
Message-ID: <AANLkTimW247sL7mVKChOVjGFTcSA4mYZhwXdasfaYzXN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:57215 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961Ab1AIOjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 09:39:15 -0500
Received: by eye27 with SMTP id 27so8246395eye.19
        for <netdev@vger.kernel.org>; Sun, 09 Jan 2011 06:39:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear All,

My final year project is all about MAC address spoofing.

I do know that I can reset the MAC address of my network adapter to
its original by rebooting the Linux operating system I am using.

My Linux distribution is using NetworkManager. On Wireless network,
each time after I change the MAC address of my wireless network
adapter and then connect to the wireless network, and then once I
disconnect from wireless network, NetworkManager will reset the MAC
address of my wireless network adapter to its original.

I had programmed my application to change the MAC address. Now, trying
to implement the feature that reset the MAC address. I don't know
whether NetworkManager record down the original MAC address of my
Network Adapter or not. But, assume if NetworkManager is able to reset
the MAC address of my network adapter to its original MAC address
without recording the original MAC address and without reboot, then my
application must be able to do the same.

So, can anyone tell me the C++ codes that is able to reset the MAC
address, or give me some ideas on this, please?

Regards,
