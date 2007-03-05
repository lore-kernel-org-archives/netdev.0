From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH][UDP]: Fix "whitespace" cleanup
Date: Mon, 5 Mar 2007 00:11:49 -0300
Message-ID: <39e6f6c70703041911u446bb4a0q324d5087237a57a7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_125375_17805900.1173064309753"
Cc: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	"Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:14593 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610AbXCEDLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 22:11:52 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1126519uga
        for <netdev@vger.kernel.org>; Sun, 04 Mar 2007 19:11:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_125375_17805900.1173064309753
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi David, Stephen

       Whitespace cleanups have to pass the compile test too ;-) This
is just in net-2.6.22 tho :-)

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

- Arnaldo

------=_Part_125375_17805900.1173064309753
Content-Type: text/x-patch; name=udp.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_eywc4hbl
Content-Disposition: attachment; filename="udp.patch"

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L3VkcC5jIGIvbmV0L2lwdjQvdWRwLmMKaW5kZXggNTMwOWRk
NS4uMmU5ZmQxZSAxMDA2NDQKLS0tIGEvbmV0L2lwdjQvdWRwLmMKKysrIGIvbmV0L2lwdjQvdWRw
LmMKQEAgLTE5Niw3ICsxOTYsNyBAQCBnb3RpdDoKIAkJCWlmIChzazItPnNrX2hhc2ggPT0gc251
bSAgICAgICAgICAgICAgICAgICAgICAgICAgICAgJiYKIAkJCSAgICBzazIgIT0gc2sgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgJiYKIAkJCSAgICAoIXNrMi0+c2tfcmV1
c2UgICAgICAgIHx8ICFzay0+c2tfcmV1c2UpICAgICAgICAgJiYKLQkJCSAgICAgfHwgc2syLT5z
a19ib3VuZF9kZXZfaWYgPT0gc2stPnNrX2JvdW5kX2Rldl9pZikgJiYKKwkJCSAgICAoc2syLT5z
a19ib3VuZF9kZXZfaWYgPT0gc2stPnNrX2JvdW5kX2Rldl9pZikgICAgJiYKIAkJCSAgICAoKnNh
ZGRyX2NvbXApKHNrLCBzazIpKQogCQkJCWdvdG8gZmFpbDsKIAl9Cg==
------=_Part_125375_17805900.1173064309753--
