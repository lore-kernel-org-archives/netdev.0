From: "Enrico Mioso (@atlantide)" <mrkiko.rs@gmail.com>
Subject: Fault ammission :)
Date: Mon, 7 Apr 2014 10:55:36 +0200 (CEST)
Message-ID: <alpine.LNX.2.03.1404071046430.2161@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Oliver Neukum <oliver@neukum.org>, gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:55899 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbaDGIyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 04:54:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just to say - that my first COMMIT (adding support fo ONDA MT828UP) was simply 
wrong. There was a firmware update, but it didn't influence the thing, so I 
simply mistaken. But now, with the latter commit fixing the thing, all works 
fine.
I will be better to keep udev running :) .
References:
- Patch: "usb: serial: option.c: remove ONDA MT825UP product ID fromdriver"
- (indirect references in this one)

Thank you for attention and reading,

Enrico
