From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dpaa: remove init which already done in
 per-cpu allocation
Date: Wed, 01 Nov 2017 12:09:05 +0900 (KST)
Message-ID: <20171101.120905.1863399513981852883.davem@davemloft.net>
References: <1509241724-16997-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, Linyu.Yuan@alcatel-sbell.com.cn
To: cugyly@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44620 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752009AbdKADJI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 23:09:08 -0400
In-Reply-To: <1509241724-16997-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogeXVhbiBsaW55dSA8Y3VneWx5QDE2My5jb20+DQpEYXRlOiBTdW4sIDI5IE9jdCAyMDE3
IDA5OjQ4OjQ0ICswODAwDQoNCj4gRnJvbTogeXVhbiBsaW55dSA8TGlueXUuWXVhbkBhbGNhdGVs
LXNiZWxsLmNvbS5jbj4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IHl1YW4gbGlueXUgPExpbnl1Lll1
YW5AYWxjYXRlbC1zYmVsbC5jb20uY24+DQoNClBsZWFzZSBjb21waWxlIHRlc3QgeW91ciBwYXRj
aGVzIGFuZCB3YXRjaCBmb3Igd2FybmluZ3M6DQoNCmRyaXZlcnMvbmV0L2V0aGVybmV0L2ZyZWVz
Y2FsZS9kcGFhL2RwYWFfZXRoLmM6IEluIGZ1bmN0aW9uIKFkcGFhX2V0aF9wcm9iZaI6DQpkcml2
ZXJzL25ldC9ldGhlcm5ldC9mcmVlc2NhbGUvZHBhYS9kcGFhX2V0aC5jOjI2NzE6Mjc6IHdhcm5p
bmc6IHVudXNlZCB2YXJpYWJsZSChcGVyY3B1X3ByaXaiIFstV3VudXNlZC12YXJpYWJsZV0NCiAg
c3RydWN0IGRwYWFfcGVyY3B1X3ByaXYgKnBlcmNwdV9wcml2Ow0KICAgICAgICAgICAgICAgICAg
ICAgICAgICAgXn5+fn5+fn5+fn4NCmRyaXZlcnMvbmV0L2V0aGVybmV0L2ZyZWVzY2FsZS9kcGFh
L2RwYWFfZXRoLmM6IEluIGZ1bmN0aW9uIKFkcGFhX29wZW6iOg0KZHJpdmVycy9uZXQvZXRoZXJu
ZXQvZnJlZXNjYWxlL2RwYWEvZHBhYV9ldGguYzoyNDk3Ojk6IHdhcm5pbmc6IKFlcnKiIG1heSBi
ZSB1c2VkIHVuaW5pdGlhbGl6ZWQgaW4gdGhpcyBmdW5jdGlvbiBbLVdtYXliZS11bmluaXRpYWxp
emVkXQ0KICByZXR1cm4gZXJyOw0KICAgICAgICAgXn5+DQo=
