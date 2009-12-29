From: thomas yang <lampsu@gmail.com>
Subject: Ethernet CRC questions
Date: Wed, 30 Dec 2009 01:17:57 +0800
Message-ID: <f4f837ab0912290917h626bcfecy34fe095a878e733c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:41934 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbZL2RR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 12:17:58 -0500
Received: by pwj9 with SMTP id 9so6900240pwj.21
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2009 09:17:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

How does Linux  generate Ethernet CRC ?
by the hardware (Ethernet controller)  or  use crc32_le() /
crc32_be()     ( lib/crc32.c )  ?

P.S.   my  network card is  rtl8139d  , use  8139too driver


--
thomas
