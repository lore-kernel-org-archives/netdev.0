From: Rahul Jain <rahul@schmizz.net>
Subject: MAC/PHY layer implementation questions
Date: Sun, 8 Mar 2009 00:15:22 +0100
Message-ID: <655e2d30903071515s4a50c758j39704861499bba8e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f177.google.com ([209.85.219.177]:35643 "EHLO
	mail-ew0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbZCGXPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 18:15:25 -0500
Received: by ewy25 with SMTP id 25so491987ewy.37
        for <netdev@vger.kernel.org>; Sat, 07 Mar 2009 15:15:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am working on a related project for my Bachelor's
thesis and would really appreciate any help that I can get in this regard. I
am supposed to develop a device driver for the IEEE 802.15.4 nanoLOC
transceiver (for Linux boards) and I have a few questions about how exactly to
go about it.

As far as I understand it, I first need a kernel stack for IEEE 802.15.4 (as
far as I understand mac80211 is the kernel stack for the IEEE 802.11 and I
would need something similar). This Kernel stack, as I understand it, would
then provide a common API for driver development.

So, I would really appreciate if some one could inform me as to what exactly
does programming this stack incorporate? Do I need to implement the PHY and
the MAC layers, and if yes, how do I go about that?


Please Help!

Thanks
Rahul Jain
