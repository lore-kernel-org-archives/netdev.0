From: Anand Raj Manickam <anandrm@gmail.com>
Subject: RTL-8139C Link NOT detected in Linux 3.4.4 kernel
Date: Fri, 6 Jul 2012 13:12:03 +0530
Message-ID: <CAEyr1FQi16LCh4oRD6cdFyi6NJwjUuq9BP-rB6eTeeJDWCibxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:50809 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850Ab2GFHmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 03:42:04 -0400
Received: by gglu4 with SMTP id u4so8296234ggl.19
        for <netdev@vger.kernel.org>; Fri, 06 Jul 2012 00:42:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I m running a 3.4.4 kernel , i face a strange issue where the Link on
8139too driver for RTL-8139C is not detected.
The same works great if i revert the kernel back to 2.6.36.
Anybody faced the same ?
