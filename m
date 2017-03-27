From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/8] Add support for pipeline debug (dpipe)
Date: Mon, 27 Mar 2017 15:48:34 -0700 (PDT)
Message-ID: <20170327.154834.1733255928137862540.davem@davemloft.net>
References: <1490427342-2061-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, ivecera@redhat.com,
        roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com,
        andrew@lunn.ch, simon.horman@netronome.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52678 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752620AbdC0Wsn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 18:48:43 -0400
In-Reply-To: <1490427342-2061-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQpQbGVhc2UgZml4IHVwIHRoZXNlIHdhcm5pbmdzIGFuZCByZXN1Ym1pdDoNCg0KZHJpdmVycy9u
ZXQvZXRoZXJuZXQvbWVsbGFub3gvbWx4c3cvc3BlY3RydW1fcm91dGVyLmM6IEluIGZ1bmN0aW9u
IKFtbHhzd19zcF9yaWZfY291bnRlcl9mcmVlojoNCmRyaXZlcnMvbmV0L2V0aGVybmV0L21lbGxh
bm94L21seHN3L3NwZWN0cnVtX3JvdXRlci5jOjIwODoyOiB3YXJuaW5nOiChcF9jb3VudGVyX2lu
ZGV4oiBtYXkgYmUgdXNlZCB1bmluaXRpYWxpemVkIGluIHRoaXMgZnVuY3Rpb24gWy1XbWF5YmUt
dW5pbml0aWFsaXplZF0NCiAgbWx4c3dfc3BfcmlmX2NvdW50ZXJfZWRpdChtbHhzd19zcCwgcmlm
LT5yaWZfaW5kZXgsDQogIF4NCmRyaXZlcnMvbmV0L2V0aGVybmV0L21lbGxhbm94L21seHN3L3Nw
ZWN0cnVtX2RwaXBlLmM6IEluIGZ1bmN0aW9uIKFtbHhzd19zcF90YWJsZV9lcmlmX2VudHJpZXNf
ZHVtcKI6DQpkcml2ZXJzL25ldC9ldGhlcm5ldC9tZWxsYW5veC9tbHhzdy9zcGVjdHJ1bV9kcGlw
ZS5jOjIyMDo5OiB3YXJuaW5nOiBtaXNzaW5nIGJyYWNlcyBhcm91bmQgaW5pdGlhbGl6ZXIgWy1X
bWlzc2luZy1icmFjZXNdDQogIHN0cnVjdCBkZXZsaW5rX2RwaXBlX3ZhbHVlIG1hdGNoX3ZhbHVl
ID0gezB9LCBhY3Rpb25fdmFsdWUgPSB7MH07DQogICAgICAgICBeDQpkcml2ZXJzL25ldC9ldGhl
cm5ldC9tZWxsYW5veC9tbHhzdy9zcGVjdHJ1bV9kcGlwZS5jOjIyMDo5OiB3YXJuaW5nOiAobmVh
ciBpbml0aWFsaXphdGlvbiBmb3IgoW1hdGNoX3ZhbHVlLjxhbm9ueW1vdXM+oikgWy1XbWlzc2lu
Zy1icmFjZXNdDQpkcml2ZXJzL25ldC9ldGhlcm5ldC9tZWxsYW5veC9tbHhzdy9zcGVjdHJ1bV9k
cGlwZS5jOjIyMDo5OiB3YXJuaW5nOiBtaXNzaW5nIGJyYWNlcyBhcm91bmQgaW5pdGlhbGl6ZXIg
Wy1XbWlzc2luZy1icmFjZXNdDQpkcml2ZXJzL25ldC9ldGhlcm5ldC9tZWxsYW5veC9tbHhzdy9z
cGVjdHJ1bV9kcGlwZS5jOjIyMDo5OiB3YXJuaW5nOiAobmVhciBpbml0aWFsaXphdGlvbiBmb3Ig
oWFjdGlvbl92YWx1ZS48YW5vbnltb3VzPqIpIFstV21pc3NpbmctYnJhY2VzXQ0K
