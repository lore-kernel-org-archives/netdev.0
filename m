From: Gopakumar Choorakkot Edakkunni <gopakumar.c.e@gmail.com>
Subject: protocol 0806 is buggy, dev usb0
Date: Fri, 9 Jan 2015 03:16:37 -0800
Message-ID: <CABK1yFBbOY1iqSaADsRkrR7A6Mo6JnLECYVXZqUM7Ki67O+KsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f53.google.com ([209.85.213.53]:44071 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932671AbbAILQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 06:16:38 -0500
Received: by mail-yh0-f53.google.com with SMTP id i57so3820509yha.12
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 03:16:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a ZTE MF823 modem (kernel version is 3.12.27) using cdc-ether driver
which gives a usb0 interface. It works well for the most part, but I keep
seeing the below messages in dmesg once in every 5 seconds. Its clearly
complaining about the ARP packets, the modem has some instability issues,
not sure if thats related to this message. A googling doesnt give much info
other than users reporting this once in a while - if anyone has more info
about this please share, that will be of great help !

"protocol 0806 is buggy, dev usb0"

Rgds,
Gopa.
