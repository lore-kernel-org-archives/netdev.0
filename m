From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-2.6 ] ipv4: remove parameter from tcp_recv_urg().
Date: Mon, 16 Mar 2009 11:57:20 +0200
Message-ID: <eb3ff54b0903160257n707ceddfr1a56c75b7911c1e7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001636e90eeaf00c6e04653979b8
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:30358 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761503AbZCPJ5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 05:57:22 -0400
Received: by wf-out-1314.google.com with SMTP id 28so1827594wfa.4
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2009 02:57:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001636e90eeaf00c6e04653979b8
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,
This patch removes an unused parameter (addr_len) from tcp_recv_urg() method in
net/ipv4/tcp.c.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

--001636e90eeaf00c6e04653979b8
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fsczccfp0

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L3RjcC5jIGIvbmV0L2lwdjQvdGNwLmMKaW5kZXggNzZiMTQ4
Yi4uZmQ0OGJiYiAxMDA2NDQKLS0tIGEvbmV0L2lwdjQvdGNwLmMKKysrIGIvbmV0L2lwdjQvdGNw
LmMKQEAgLTEwNDUsOCArMTA0NSw3IEBAIG91dF9lcnI6CiAgKi8KIAogc3RhdGljIGludCB0Y3Bf
cmVjdl91cmcoc3RydWN0IHNvY2sgKnNrLCBsb25nIHRpbWVvLAotCQkJc3RydWN0IG1zZ2hkciAq
bXNnLCBpbnQgbGVuLCBpbnQgZmxhZ3MsCi0JCQlpbnQgKmFkZHJfbGVuKQorCQkJc3RydWN0IG1z
Z2hkciAqbXNnLCBpbnQgbGVuLCBpbnQgZmxhZ3MpCiB7CiAJc3RydWN0IHRjcF9zb2NrICp0cCA9
IHRjcF9zayhzayk7CiAKQEAgLTE2NjEsNyArMTY2MCw3IEBAIG91dDoKIAlyZXR1cm4gZXJyOwog
CiByZWN2X3VyZzoKLQllcnIgPSB0Y3BfcmVjdl91cmcoc2ssIHRpbWVvLCBtc2csIGxlbiwgZmxh
Z3MsIGFkZHJfbGVuKTsKKwllcnIgPSB0Y3BfcmVjdl91cmcoc2ssIHRpbWVvLCBtc2csIGxlbiwg
ZmxhZ3MpOwogCWdvdG8gb3V0OwogfQogCg==
--001636e90eeaf00c6e04653979b8--
