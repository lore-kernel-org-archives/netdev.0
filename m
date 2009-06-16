From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next-2.6] udp: remove unused union in udp_skb_cb.
Date: Tue, 16 Jun 2009 11:50:11 +0300
Message-ID: <eb3ff54b0906160150n74fb8984u84a366f5e472b4c3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0015174c136e3bdecd046c734382
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:11817 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754733AbZFPIuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 04:50:11 -0400
Received: by ey-out-2122.google.com with SMTP id 25so410558eya.37
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2009 01:50:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0015174c136e3bdecd046c734382
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,
This cleanup patch removes an unused union (header) in udp_skb_cb.
(include/net/udp.h)

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

--0015174c136e3bdecd046c734382
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fw0dbp7h0

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L3VkcC5oIGIvaW5jbHVkZS9uZXQvdWRwLmgKaW5kZXgg
OTBlNmNlNS4uZmIzMDMxYiAxMDA2NDQKLS0tIGEvaW5jbHVkZS9uZXQvdWRwLmgKKysrIGIvaW5j
bHVkZS9uZXQvdWRwLmgKQEAgLTM0LDE3ICszNCwxMCBAQAogLyoqCiAgKglzdHJ1Y3QgdWRwX3Nr
Yl9jYiAgLSAgVURQKC1MaXRlKSBwcml2YXRlIHZhcmlhYmxlcwogICoKLSAqCUBoZWFkZXI6ICAg
ICAgcHJpdmF0ZSB2YXJpYWJsZXMgdXNlZCBieSBJUHY0L0lQdjYKICAqCUBjc2NvdjogICAgICAg
Y2hlY2tzdW0gY292ZXJhZ2UgbGVuZ3RoIChVRFAtTGl0ZSBvbmx5KQogICoJQHBhcnRpYWxfY292
OiBpZiBzZXQgaW5kaWNhdGVzIHBhcnRpYWwgY3N1bSBjb3ZlcmFnZQogICovCiBzdHJ1Y3QgdWRw
X3NrYl9jYiB7Ci0JdW5pb24gewotCQlzdHJ1Y3QgaW5ldF9za2JfcGFybQloNDsKLSNpZiBkZWZp
bmVkKENPTkZJR19JUFY2KSB8fCBkZWZpbmVkIChDT05GSUdfSVBWNl9NT0RVTEUpCi0JCXN0cnVj
dCBpbmV0Nl9za2JfcGFybQloNjsKLSNlbmRpZgotCX0gaGVhZGVyOwogCV9fdTE2CQljc2NvdjsK
IAlfX3U4CQlwYXJ0aWFsX2NvdjsKIH07Cg==
--0015174c136e3bdecd046c734382--
