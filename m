From: =?UTF-8?B?Si5QdWrDsw==?= <jpujob@gmail.com>
Subject: ITECIR 8710 not recognized by any kernel
Date: Thu, 22 Jan 2015 17:00:53 +0100
Message-ID: <CAO39EDh1RCAC46=+MFYkxFzH5ZcZ00G866SBNfFxWLyOvDdo-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:51495 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbbAVQBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 11:01:14 -0500
Received: by mail-ob0-f176.google.com with SMTP id va2so2168895obc.7
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 08:01:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

My laptop comes with a ITECIR 8710 infrared receiver, but is not
recognized by any kernel. I tried newer and older versions but nothing
changed.

It's an integrated infrared receiver, which is working like a charm on
Windows partition, so the device is working (obviously, not in Linux).

I tried to search on the net, but I couldn't see anything useful to
make it work with Linux. I guess the drivers never were developed. Is
that possible?

Moreover, there is no /dev/lircX nor /sys/class/rc on my system. So
it's not recognized at all.

Here you have journalctl, dmesg, lsusb, lspci and lircd log.

journalctl: https://dl.dropboxusercontent.com/u/2135959/journalctl.txt
dmesg: https://dl.dropboxusercontent.com/u/2135959/dmesg.txt
lsusb: https://dl.dropboxusercontent.com/u/2135959/lsusb.txt
lspci: https://dl.dropboxusercontent.com/u/2135959/lspci.txt
lircd: https://dl.dropboxusercontent.com/u/2135959/lircd

Let me know if you need more info or details and if it's possible to
make it work with Linux.

Thanks.
