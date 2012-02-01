From: Prashant Badsheshi <prashant.badsheshi@gmail.com>
Subject: Regarding carl9170 wifi linux driver
Date: Wed, 1 Feb 2012 07:46:49 +0530
Message-ID: <CA+cdTWZsiCa6ccBjgybAc0EZBLT8xSqEgB=wVzNT_wHPZry-vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:36106 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753716Ab2BACQv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 21:16:51 -0500
Received: by vcge1 with SMTP id e1so646454vcg.19
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 18:16:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We are planning to use the below wifi dongle as station and AP.

https://www.thinkpenguin.com/gnu-linux/penguin-wireless-n-usb-adapter



We got the linux driver from the below path

git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-testing=
=2Egit



We found the driver source in drivers/net/wireless/ath/carl9170.



Our Question:

Is the carl9170 driver present in the above folder is a complete open
source driver?

Or is it not complete driver and is there any NON-GPL code that is not
provided as an open source?

Please clarify it. Your immediate response would be really appreciated.



Also it would be great if there is any design document or programmer=92=
s
document for the above mentioned Wifi dongle chipset available.



Regards,

Prashant
