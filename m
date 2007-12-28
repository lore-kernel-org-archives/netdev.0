From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.25] [IPv4] Remove unused define in include/net/arp.h (HAVE_ARP_CREATE)
Date: Fri, 28 Dec 2007 17:20:34 +0200
Message-ID: <eb3ff54b0712280720r723856afi55f591e214b7ed14@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_2330_3990107.1198855234171"
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:60554 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964AbXL1PUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2007 10:20:39 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1945178fga.17
        for <netdev@vger.kernel.org>; Fri, 28 Dec 2007 07:20:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_2330_3990107.1198855234171
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,

It seems to me that the HAVE_ARP_CREATE (empty) definition, from
include/net/arp.h, can be removed,
since it is not used anywhere in the kernel.

Regards,
Rami Rosen

http://www.linux-foundation.org/en/Net:Network_Overview

Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_2330_3990107.1198855234171
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_faqv7mrk0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2FycC5oIGIvaW5jbHVkZS9uZXQvYXJwLmgKaW5kZXgg
MzY0ODJiZi4uNzUyZWI0NyAxMDA2NDQKLS0tIGEvaW5jbHVkZS9uZXQvYXJwLmgKKysrIGIvaW5j
bHVkZS9uZXQvYXJwLmgKQEAgLTUsNyArNSw2IEBACiAjaW5jbHVkZSA8bGludXgvaWZfYXJwLmg+
CiAjaW5jbHVkZSA8bmV0L25laWdoYm91ci5oPgogCi0jZGVmaW5lIEhBVkVfQVJQX0NSRUFURQog
CiBleHRlcm4gc3RydWN0IG5laWdoX3RhYmxlIGFycF90Ymw7CiAK
------=_Part_2330_3990107.1198855234171--
