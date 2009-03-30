From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-2.6 ] ipv4: remove unused parameter from tcp_recv_urg().
Date: Mon, 30 Mar 2009 17:11:30 +0300
Message-ID: <eb3ff54b0903300711l34b6f883kda27683b344bbcac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=000e0cd24e22ba305b046656a8f3
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:33731 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118AbZC3OLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 10:11:33 -0400
Received: by fxm2 with SMTP id 2so1983191fxm.37
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2009 07:11:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--000e0cd24e22ba305b046656a8f3
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,
This patch removes an unused parameter (timeo) from tcp_recv_urg() method in
net/ipv4/tcp.c.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

--000e0cd24e22ba305b046656a8f3
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fsx8kwzc0

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L3RjcC5jIGIvbmV0L2lwdjQvdGNwLmMKaW5kZXggMjQ1MWFl
Yi4uZmFmYmVjOCAxMDA2NDQKLS0tIGEvbmV0L2lwdjQvdGNwLmMKKysrIGIvbmV0L2lwdjQvdGNw
LmMKQEAgLTEwODEsOCArMTA4MSw3IEBAIG91dF9lcnI6CiAgKgl0aGlzLCBubyBibG9ja2luZyBh
bmQgdmVyeSBzdHJhbmdlIGVycm9ycyA4KQogICovCiAKLXN0YXRpYyBpbnQgdGNwX3JlY3ZfdXJn
KHN0cnVjdCBzb2NrICpzaywgbG9uZyB0aW1lbywKLQkJCXN0cnVjdCBtc2doZHIgKm1zZywgaW50
IGxlbiwgaW50IGZsYWdzKQorc3RhdGljIGludCB0Y3BfcmVjdl91cmcoc3RydWN0IHNvY2sgKnNr
LCBzdHJ1Y3QgbXNnaGRyICptc2csIGludCBsZW4sIGludCBmbGFncykKIHsKIAlzdHJ1Y3QgdGNw
X3NvY2sgKnRwID0gdGNwX3NrKHNrKTsKIApAQCAtMTY5Nyw3ICsxNjk2LDcgQEAgb3V0OgogCXJl
dHVybiBlcnI7CiAKIHJlY3ZfdXJnOgotCWVyciA9IHRjcF9yZWN2X3VyZyhzaywgdGltZW8sIG1z
ZywgbGVuLCBmbGFncyk7CisJZXJyID0gdGNwX3JlY3ZfdXJnKHNrLCBtc2csIGxlbiwgZmxhZ3Mp
OwogCWdvdG8gb3V0OwogfQogCg==
--000e0cd24e22ba305b046656a8f3--
