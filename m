From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.25] [BRIDGE] Remove unused macros from ebt_vlan.c
Date: Tue, 8 Jan 2008 16:38:15 +0200
Message-ID: <eb3ff54b0801080638j48b51978j9beb11b310ef2b8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_10569_6770878.1199803095885"
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:9078 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328AbYAHOiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 09:38:17 -0500
Received: by fg-out-1718.google.com with SMTP id e21so4507540fga.17
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2008 06:38:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_10569_6770878.1199803095885
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

 Remove two unused macros, INV_FLAG and SET_BITMASK
 from net/bridge/netfilter/ebt_vlan.c.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_10569_6770878.1199803095885
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fb6jj9hg0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL25ldC9icmlkZ2UvbmV0ZmlsdGVyL2VidF92bGFuLmMgYi9uZXQvYnJpZGdl
L25ldGZpbHRlci9lYnRfdmxhbi5jCmluZGV4IGE0M2M2OTcuLjBkZGY3NDkgMTAwNjQ0Ci0tLSBh
L25ldC9icmlkZ2UvbmV0ZmlsdGVyL2VidF92bGFuLmMKKysrIGIvbmV0L2JyaWRnZS9uZXRmaWx0
ZXIvZWJ0X3ZsYW4uYwpAQCAtMzcsOSArMzcsNyBAQCBNT0RVTEVfTElDRU5TRSgiR1BMIik7CiAK
IAogI2RlZmluZSBERUJVR19NU0coYXJncy4uLikgaWYgKGRlYnVnKSBwcmludGsgKEtFUk5fREVC
VUcgImVidF92bGFuOiAiIGFyZ3MpCi0jZGVmaW5lIElOVl9GTEFHKF9pbnZfZmxhZ18pIChpbmZv
LT5pbnZmbGFncyAmIF9pbnZfZmxhZ18pID8gIiEiIDogIiIKICNkZWZpbmUgR0VUX0JJVE1BU0so
X0JJVF9NQVNLXykgaW5mby0+Yml0bWFzayAmIF9CSVRfTUFTS18KLSNkZWZpbmUgU0VUX0JJVE1B
U0soX0JJVF9NQVNLXykgaW5mby0+Yml0bWFzayB8PSBfQklUX01BU0tfCiAjZGVmaW5lIEVYSVRf
T05fTUlTTUFUQ0goX01BVENIXyxfTUFTS18pIHtpZiAoISgoaW5mby0+X01BVENIXyA9PSBfTUFU
Q0hfKV4hIShpbmZvLT5pbnZmbGFncyAmIF9NQVNLXykpKSByZXR1cm4gRUJUX05PTUFUQ0g7fQog
CiBzdGF0aWMgaW50Cg==
------=_Part_10569_6770878.1199803095885--
