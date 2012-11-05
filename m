From: "devendra.aaru" <devendra.aaru@gmail.com>
Subject: how to disable automatic route addition for an ipv6 address
Date: Mon, 5 Nov 2012 12:52:16 -0500
Message-ID: <CAHdPZaPt-ybmZiS5uzdos6OYC2q8BBmFfSgSQ0RnOe4AnPpcdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:37331 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901Ab2KERwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 12:52:17 -0500
Received: by mail-vb0-f46.google.com with SMTP id ff1so6140403vbb.19
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2012 09:52:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

while adding the ipv6 address to interface ,

ifconfig eth0 add 2001:8800:10fb:4444::ae/64

i am seeing the route addition automatically

route -n -A inet6 shows that one of the route from the above added address.

how to disable the automatic route addition?

or is it something that ipv6 protocol itself does?


thanks,
