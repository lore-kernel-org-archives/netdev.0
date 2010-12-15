From: David Shwatrz <dshwatrz@gmail.com>
Subject: [PATCH net-next-2.6] Documentation/networking/l2tp.txt: update documentation.
Date: Wed, 15 Dec 2010 20:40:38 +0200
Message-ID: <AANLkTimhKtb+p6-4bG7QXBmUZ5YX=m5u1ZkxEb94e1K1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016e6daa8a50e7cba049777464a
To: davem@davemloft.net, netdev@vger.kernel.org, jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49379 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754420Ab0LOSkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 13:40:42 -0500
Received: by wyb28 with SMTP id 28so1751551wyb.19
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 10:40:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016e6daa8a50e7cba049777464a
Content-Type: text/plain; charset=ISO-8859-1

Hi,

This patch updates Documentation/networking/l2tp.txt.
Stephen Hemminger (maintainer of iproute2) rejected patches for
iproute2 which enable
"ip l2tp" commands. There is a utility called l2tpv3tun which
has commands to doing the same (managing static L2TPv3 tunnel).
see:
http://www.spinics.net/lists/netdev/msg142037.html


Regards,
David Shwartz

Signed-off-by: David Shwartz <dshwatrz@gmail.com>

--0016e6daa8a50e7cba049777464a
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ghqkecj61

ZGlmZiAtLWdpdCBhL0RvY3VtZW50YXRpb24vbmV0d29ya2luZy9sMnRwLnR4dCBiL0RvY3VtZW50
YXRpb24vbmV0d29ya2luZy9sMnRwLnR4dAppbmRleCBlN2JmMzk3Li5lYjY1MTBlIDEwMDY0NAot
LS0gYS9Eb2N1bWVudGF0aW9uL25ldHdvcmtpbmcvbDJ0cC50eHQKKysrIGIvRG9jdW1lbnRhdGlv
bi9uZXR3b3JraW5nL2wydHAudHh0CkBAIC0xNjUsNiArMTY1LDEwIEBAIGNhc2UgLS0gdGhlIHR1
bm5lbCBzb2NrZXQgaXMgY3JlYXRlZCBieSB0aGUga2VybmVsIGFuZCBjb25maWd1cmVkCiB1c2lu
ZyBwYXJhbWV0ZXJzIHNlbnQgaW4gdGhlIEwyVFBfQ01EX1RVTk5FTF9DUkVBVEUgbmV0bGluawog
cmVxdWVzdC4gVGhlICJpcCIgdXRpbGl0eSBvZiBpcHJvdXRlMiBoYXMgY29tbWFuZHMgZm9yIG1h
bmFnaW5nIHN0YXRpYwogTDJUUHYzIHR1bm5lbHM7IGRvICJpcCBsMnRwIGhlbHAiIGZvciBtb3Jl
IGluZm9ybWF0aW9uLgorVGhlICJsMnRwdjN0dW4iIHV0aWxpdHkgaGFzIGNvbW1hbmRzIGZvciBt
YW5hZ2luZyBzdGF0aWMKK0wyVFB2MyB0dW5uZWxzOyBkbyAibDJ0cHYzdHVuIGhlbHAiIGZvciBt
b3JlIGluZm9ybWF0aW9uLiAgIAorbDJ0cHYzdHVuIGNhbiBiZSBkb3dubG9hZCBmcm9tOiBoZnRw
Oi8vZnRwLm9wZW5sMnRwLm9yZy9yZWxlYXNlcworCiAKIERlYnVnZ2luZwogPT09PT09PT09CkBA
IC0yMTYsOSArMjIwLDkgQEAgdHVubmVsIGVuZHBvaW50czotCiAjIG1vZHByb2JlIGwydHBfZXRo
CiAjIG1vZHByb2JlIGwydHBfbmV0bGluawogCi0jIGlwIGwydHAgYWRkIHR1bm5lbCB0dW5uZWxf
aWQgMSBwZWVyX3R1bm5lbF9pZCAxIHVkcF9zcG9ydCA1MDAwIFwKKyMgbDJ0cHYzdHVuIGFkZCB0
dW5uZWwgdHVubmVsX2lkIDEgcGVlcl90dW5uZWxfaWQgMSB1ZHBfc3BvcnQgNTAwMCBcCiAgIHVk
cF9kcG9ydCA1MDAwIGVuY2FwIHVkcCBsb2NhbCAxOTIuMTY4LjEuMSByZW1vdGUgMTkyLjE2OC4x
LjIKLSMgaXAgbDJ0cCBhZGQgc2Vzc2lvbiB0dW5uZWxfaWQgMSBzZXNzaW9uX2lkIDEgcGVlcl9z
ZXNzaW9uX2lkIDEKKyMgbDJ0cHYzdHVuIGFkZCBzZXNzaW9uIHR1bm5lbF9pZCAxIHNlc3Npb25f
aWQgMSBwZWVyX3Nlc3Npb25faWQgMQogIyBpZmNvbmZpZyAtYQogIyBpcCBhZGRyIGFkZCAxMC41
LjEuMi8zMiBwZWVyIDEwLjUuMS4xLzMyIGRldiBsMnRwZXRoMAogIyBpZmNvbmZpZyBsMnRwZXRo
MCB1cAo=
--0016e6daa8a50e7cba049777464a--
