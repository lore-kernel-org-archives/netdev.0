From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/9] udp: make local function static
Date: Sun, 21 May 2017 13:43:20 -0400 (EDT)
Message-ID: <20170521.134320.732370789803344305.davem@davemloft.net>
References: <20170519165556.483-1-sthemmin@microsoft.com>
        <20170519165556.483-4-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45190 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756582AbdEURnW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 13:43:22 -0400
In-Reply-To: <20170519165556.483-4-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogU3RlcGhlbiBIZW1taW5nZXIgPHN0ZXBoZW5AbmV0d29ya3BsdW1iZXIub3JnPg0KRGF0
ZTogRnJpLCAxOSBNYXkgMjAxNyAwOTo1NTo1MCAtMDcwMA0KDQo+IHVkcF9xdWV1ZV9yY3Zfc2ti
IHdhcyBnbG9iYWwgYnV0IG9ubHkgdXNlZCBpbiBvbmUgZmlsZS4NCj4gSWRlbnRpZmllZCBieSB0
aGlzIHdhcm5pbmc6DQo+IG5ldC9pcHY0L3VkcC5jOjE3NzU6NTogd2FybmluZzogbm8gcHJldmlv
dXMgcHJvdG90eXBlIGZvciChdWRwX3F1ZXVlX3Jjdl9za2KiIFstV21pc3NpbmctcHJvdG90eXBl
c10NCj4gIGludCB1ZHBfcXVldWVfcmN2X3NrYihzdHJ1Y3Qgc29jayAqc2ssIHN0cnVjdCBza19i
dWZmICpza2IpDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBTdGVwaGVuIEhlbW1pbmdlciA8c3RoZW1t
aW5AbWljcm9zb2Z0LmNvbT4NCg0KQWxyZWFkeSBmaXhlZCBpbiBuZXQtbmV4dCwgcGxlYXNlIGdl
bmVyYXRlIHBhdGNoZXMgYWdhaW5zdA0KY3VycmVudCBzb3VyY2VzLg0K
