From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/8] Add support for pipeline debug (dpipe)
Date: Tue, 28 Mar 2017 11:00:07 -0700 (PDT)
Message-ID: <20170328.110007.875421280068278494.davem@davemloft.net>
References: <1490427342-2061-1-git-send-email-jiri@resnulli.us>
        <20170327.154834.1733255928137862540.davem@davemloft.net>
        <20170328065111.GA1873@nanopsycho.orion>
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
Received: from shards.monkeyblade.net ([184.105.139.130]:34808 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752724AbdC1SAK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 14:00:10 -0400
In-Reply-To: <20170328065111.GA1873@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSmlyaSBQaXJrbyA8amlyaUByZXNudWxsaS51cz4NCkRhdGU6IFR1ZSwgMjggTWFyIDIw
MTcgMDg6NTE6MTEgKzAyMDANCg0KPiBUdWUsIE1hciAyOCwgMjAxNyBhdCAxMjo0ODozNEFNIENF
U1QsIGRhdmVtQGRhdmVtbG9mdC5uZXQgd3JvdGU6DQo+Pg0KPj5QbGVhc2UgZml4IHVwIHRoZXNl
IHdhcm5pbmdzIGFuZCByZXN1Ym1pdDoNCj4+DQo+PmRyaXZlcnMvbmV0L2V0aGVybmV0L21lbGxh
bm94L21seHN3L3NwZWN0cnVtX3JvdXRlci5jOiBJbiBmdW5jdGlvbiChbWx4c3dfc3BfcmlmX2Nv
dW50ZXJfZnJlZaI6DQo+PmRyaXZlcnMvbmV0L2V0aGVybmV0L21lbGxhbm94L21seHN3L3NwZWN0
cnVtX3JvdXRlci5jOjIwODoyOiB3YXJuaW5nOiChcF9jb3VudGVyX2luZGV4oiBtYXkgYmUgdXNl
ZCB1bmluaXRpYWxpemVkIGluIHRoaXMgZnVuY3Rpb24gWy1XbWF5YmUtdW5pbml0aWFsaXplZF0N
Cj4+ICBtbHhzd19zcF9yaWZfY291bnRlcl9lZGl0KG1seHN3X3NwLCByaWYtPnJpZl9pbmRleCwN
Cj4+ICBeDQo+PmRyaXZlcnMvbmV0L2V0aGVybmV0L21lbGxhbm94L21seHN3L3NwZWN0cnVtX2Rw
aXBlLmM6IEluIGZ1bmN0aW9uIKFtbHhzd19zcF90YWJsZV9lcmlmX2VudHJpZXNfZHVtcKI6DQo+
PmRyaXZlcnMvbmV0L2V0aGVybmV0L21lbGxhbm94L21seHN3L3NwZWN0cnVtX2RwaXBlLmM6MjIw
Ojk6IHdhcm5pbmc6IG1pc3NpbmcgYnJhY2VzIGFyb3VuZCBpbml0aWFsaXplciBbLVdtaXNzaW5n
LWJyYWNlc10NCj4+ICBzdHJ1Y3QgZGV2bGlua19kcGlwZV92YWx1ZSBtYXRjaF92YWx1ZSA9IHsw
fSwgYWN0aW9uX3ZhbHVlID0gezB9Ow0KPiANCj4gSSBrbm93IGFib3V0IHRoaXMgd2FybmluZy4g
SSBiZWxpZXZlIHRoYXQgaXQgaXMgYSBnY2MgYnVnLiBJdCBoYXBwZW5zDQo+IGZvciBnY2MgNCwg
YnV0IGdjYyA2IGlzIHNpbGVudCwgdGhlcmVmb3JlIEkgY2hvb3NlIHRvIGlnbm9yZSB0aGlzLiBE
bw0KPiB5b3Ugc3RpbGwgd2FudCBtZSB0byBmaXggaXQ/DQoNClBsZWFzZSBkby4NCg==
