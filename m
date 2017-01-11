From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: Remove unused but set variable in
 __bpf_lru_list_shrink_inactive()
Date: Tue, 10 Jan 2017 21:01:37 -0500 (EST)
Message-ID: <20170110.210137.849302729948766638.davem@davemloft.net>
References: <20170110140207.26480-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, ast@kernel.org, kafai@fb.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34396 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751862AbdAKCBi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 21:01:38 -0500
In-Reply-To: <20170110140207.26480-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogVG9iaWFzIEtsYXVzZXIgPHRrbGF1c2VyQGRpc3RhbnouY2g+DQpEYXRlOiBUdWUsIDEw
IEphbiAyMDE3IDE1OjAyOjA3ICswMTAwDQoNCj4gUmVtb3ZlIHRoZSB1bnVzZWQgYnV0IHNldCB2
YXJpYWJsZSAnZmlyc3Rfbm9kZScgaW4NCj4gX19icGZfbHJ1X2xpc3Rfc2hyaW5rX2luYWN0aXZl
KCkgdG8gZml4IHRoZSBmb2xsb3dpbmcgR0NDIHdhcm5pbmcgd2hlbg0KPiBidWlsZGluZyB3aXRo
ICdXPTEnOg0KPiANCj4gICBrZXJuZWwvYnBmL2JwZl9scnVfbGlzdC5jOjIxNjo0MTogd2Fybmlu
ZzogdmFyaWFibGUgoWZpcnN0X25vZGWiIHNldCBidXQgbm90IHVzZWQgWy1XdW51c2VkLWJ1dC1z
ZXQtdmFyaWFibGVdDQo+IA0KPiBDYzogTWFydGluIEthRmFpIExhdSA8a2FmYWlAZmIuY29tPg0K
PiBTaWduZWQtb2ZmLWJ5OiBUb2JpYXMgS2xhdXNlciA8dGtsYXVzZXJAZGlzdGFuei5jaD4NCg0K
QXBwbGllZC4NCg==
