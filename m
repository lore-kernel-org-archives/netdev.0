From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: fix a compile warning in act_ife
Date: Sat, 14 Oct 2017 18:44:15 -0700 (PDT)
Message-ID: <20171014.184415.1494506034540565914.davem@davemloft.net>
References: <20171013195813.25321-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, mrv@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38372 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751237AbdJOBoP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 21:44:15 -0400
In-Reply-To: <20171013195813.25321-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQ29uZyBXYW5nIDx4aXlvdS53YW5nY29uZ0BnbWFpbC5jb20+DQpEYXRlOiBGcmksIDEz
IE9jdCAyMDE3IDEyOjU4OjEzIC0wNzAwDQoNCj4gQXBwYXJlbnRseSBpZmVfbWV0YV9pZDJuYW1l
KCkgaXMgb25seSBjYWxsZWQgd2hlbg0KPiBDT05GSUdfTU9EVUxFUyBpcyBkZWZpbmVkLg0KPiAN
Cj4gVGhpcyBmaXhlczoNCj4gDQo+IG5ldC9zY2hlZC9hY3RfaWZlLmM6MjUxOjIwOiB3YXJuaW5n
OiChaWZlX21ldGFfaWQybmFtZaIgZGVmaW5lZCBidXQgbm90IHVzZWQgWy1XdW51c2VkLWZ1bmN0
aW9uXQ0KPiAgc3RhdGljIGNvbnN0IGNoYXIgKmlmZV9tZXRhX2lkMm5hbWUodTMyIG1ldGFpZCkN
Cj4gICAgICAgICAgICAgICAgICAgICBefn5+fn5+fn5+fn5+fn5+DQo+IA0KPiBGaXhlczogZDNm
MjRiYTg5NWYwICgibmV0IHNjaGVkIGFjdGlvbnM6IGZpeCBtb2R1bGUgYXV0by1sb2FkaW5nIikN
Cj4gQ2M6IFJvbWFuIE1hc2hhayA8bXJ2QG1vamF0YXR1LmNvbT4NCj4gU2lnbmVkLW9mZi1ieTog
Q29uZyBXYW5nIDx4aXlvdS53YW5nY29uZ0BnbWFpbC5jb20+DQoNCkFwcGxpZWQuDQo=
