From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.25] [BRIDGE] Remove unused include of a header file in ebtables.c
Date: Fri, 18 Jan 2008 15:08:02 +0200
Message-ID: <eb3ff54b0801180508k7d24855ft2747224f0fb1725f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_2408_24770198.1200661682669"
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:1074 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757023AbYARNIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 08:08:04 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1031333fga.17
        for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 05:08:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_2408_24770198.1200661682669
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

In net/bridge/netfilter/ebtables.c,
- remove unused include of a header file (linux/tty.h) and remove the
  corresponding comment above it.
	
Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_2408_24770198.1200661682669
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fbkqwz9g0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL25ldC9icmlkZ2UvbmV0ZmlsdGVyL2VidGFibGVzLmMgYi9uZXQvYnJpZGdl
L25ldGZpbHRlci9lYnRhYmxlcy5jCmluZGV4IDgxNzE2OWUuLjMyYWZmZjggMTAwNjQ0Ci0tLSBh
L25ldC9icmlkZ2UvbmV0ZmlsdGVyL2VidGFibGVzLmMKKysrIGIvbmV0L2JyaWRnZS9uZXRmaWx0
ZXIvZWJ0YWJsZXMuYwpAQCAtMTUsOCArMTUsNiBAQAogICogIDIgb2YgdGhlIExpY2Vuc2UsIG9y
IChhdCB5b3VyIG9wdGlvbikgYW55IGxhdGVyIHZlcnNpb24uCiAgKi8KIAotLyogdXNlZCBmb3Ig
cHJpbnRfc3RyaW5nICovCi0jaW5jbHVkZSA8bGludXgvdHR5Lmg+CiAKICNpbmNsdWRlIDxsaW51
eC9rbW9kLmg+CiAjaW5jbHVkZSA8bGludXgvbW9kdWxlLmg+Cg==
------=_Part_2408_24770198.1200661682669--
