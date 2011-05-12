From: Chin Shi Hong <cshong87@gmail.com>
Subject: Get wireless network card or check whether an interface is a wireless card
Date: Thu, 12 May 2011 21:51:51 +0800
Message-ID: <BANLkTi=0ewCXnc0bRgCDJ7Gz=DbUeTdcyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:56426 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755929Ab1ELNvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 09:51:52 -0400
Received: by eyx24 with SMTP id 24so429960eyx.19
        for <netdev@vger.kernel.org>; Thu, 12 May 2011 06:51:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear all,

My application must display only wireless (802.11) network interface
card. Currently, by using some ioctl calls and ifreq structure, my
application currently can detect any network interface. But, I only
want my application to detect wireless network interface card.

What are the ioctl calls or c/c++ codes to do this?

Regards,
