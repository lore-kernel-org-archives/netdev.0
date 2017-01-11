From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: Make unnecessarily global functions
 static
Date: Tue, 10 Jan 2017 21:01:43 -0500 (EST)
Message-ID: <20170110.210143.1029368602579606963.davem@davemloft.net>
References: <20170110140216.26550-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, ast@kernel.org, kafai@fb.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34408 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935314AbdAKCBo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 21:01:44 -0500
In-Reply-To: <20170110140216.26550-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogVG9iaWFzIEtsYXVzZXIgPHRrbGF1c2VyQGRpc3RhbnouY2g+DQpEYXRlOiBUdWUsIDEw
IEphbiAyMDE3IDE1OjAyOjE2ICswMTAwDQoNCj4gTWFrZSB0aGUgZnVuY3Rpb25zIF9fbG9jYWxf
bGlzdF9wb3BfZnJlZSgpLCBfX2xvY2FsX2xpc3RfcG9wX3BlbmRpbmcoKSwNCj4gYnBmX2NvbW1v
bl9scnVfcG9wdWxhdGUoKSBhbmQgYnBmX3BlcmNwdV9scnVfcG9wdWxhdGUoKSBzdGF0aWMgYXMg
dGhleQ0KPiBhcmUgbm90IHVzZWQgb3V0aWRlIG9mIGJwZl9scnVfbGlzdC5jDQo+IA0KPiBUaGlz
IGZpeGVzIHRoZSBmb2xsb3dpbmcgR0NDIHdhcm5pbmdzIHdoZW4gYnVpbGRpbmcgd2l0aCAnVz0x
JzoNCj4gDQo+ICAga2VybmVsL2JwZi9icGZfbHJ1X2xpc3QuYzozNjM6MjI6IHdhcm5pbmc6IG5v
IHByZXZpb3VzIHByb3RvdHlwZSBmb3IgoV9fbG9jYWxfbGlzdF9wb3BfZnJlZaIgWy1XbWlzc2lu
Zy1wcm90b3R5cGVzXQ0KPiAgIGtlcm5lbC9icGYvYnBmX2xydV9saXN0LmM6Mzc2OjIyOiB3YXJu
aW5nOiBubyBwcmV2aW91cyBwcm90b3R5cGUgZm9yIKFfX2xvY2FsX2xpc3RfcG9wX3BlbmRpbmei
IFstV21pc3NpbmctcHJvdG90eXBlc10NCj4gICBrZXJuZWwvYnBmL2JwZl9scnVfbGlzdC5jOjU2
MDo2OiB3YXJuaW5nOiBubyBwcmV2aW91cyBwcm90b3R5cGUgZm9yIKFicGZfY29tbW9uX2xydV9w
b3B1bGF0ZaIgWy1XbWlzc2luZy1wcm90b3R5cGVzXQ0KPiAgIGtlcm5lbC9icGYvYnBmX2xydV9s
aXN0LmM6NTc3OjY6IHdhcm5pbmc6IG5vIHByZXZpb3VzIHByb3RvdHlwZSBmb3IgoWJwZl9wZXJj
cHVfbHJ1X3BvcHVsYXRloiBbLVdtaXNzaW5nLXByb3RvdHlwZXNdDQo+IA0KPiBDYzogTWFydGlu
IEthRmFpIExhdSA8a2FmYWlAZmIuY29tPg0KPiBTaWduZWQtb2ZmLWJ5OiBUb2JpYXMgS2xhdXNl
ciA8dGtsYXVzZXJAZGlzdGFuei5jaD4NCg0KQXBwbGllZC4NCg==
