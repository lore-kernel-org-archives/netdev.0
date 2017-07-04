From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [PATCH net-next] bpf: fix return in load_bpf_file
Date: Tue, 4 Jul 2017 22:55:59 +0000
Message-ID: <F15368B9-F79E-4296-958E-9DCF3CFDA7BF@fb.com>
References: <20170704215129.4047623-1-brakmo@fb.com>
 <595C1356.3000508@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Kernel Team <Kernel-team@fb.com>, Alexei Starovoitov <ast@fb.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:47506 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752174AbdGDW4e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 18:56:34 -0400
In-Reply-To: <595C1356.3000508@iogearbox.net>
Content-Language: en-US
Content-ID: <4B29EC1DB18F09418F1E8CE39E893B73@namprd15.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQpPbiA3LzQvMTcsIDM6MTQgUE0sICJEYW5pZWwgQm9ya21hbm4iIDxkYW5pZWxAaW9nZWFyYm94
Lm5ldD4gd3JvdGU6DQoNCiAgICBPbiAwNy8wNC8yMDE3IDExOjUxIFBNLCBMYXdyZW5jZSBCcmFr
bW8gd3JvdGU6DQogICAgPiBUaGUgZnVuY3Rpb24gbG9hZF9icGZfZmlsZSBpZ25vcmVzIHRoZSBy
ZXR1cm4gdmFsdWUgb2YNCiAgICA+IGxvYWRfYW5kX2F0dGFjaCgpLCBzbyBldmVuIGlmIGxvYWRf
YW5kX2F0dGFjaCgpIHJldHVybnMgYW4gZXJyb3IsDQogICAgPiBsb2FkX2JwZl9maWxlKCkgd2ls
bCByZXR1cm4gMC4NCiAgICA+DQogICAgPiBOb3csIGxvYWRfYnBmX2ZpbGUoKSBjYW4gY2FsbCBs
b2FkX2FuZF9hdHRhY2goKSBtdWx0aXBsZSB0aW1lcyBhbmQgc29tZQ0KICAgID4gY2FuIHN1Y2Nl
ZWQgYW5kIHNvbWUgY291bGQgZmFpbC4gSSB0aGluayB0aGUgY29ycmVjdCBiZWhhdm9yIGlzIHRv
DQogICAgPiByZXR1cm4gZXJyb3Igb24gdGhlIGZpcnN0IGZhaWxlZCBsb2FkX2FuZF9hdHRhY2go
KS4NCiAgICANCiAgICBZb3VyIFNPQiBpcyBtaXNzaW5nLg0KDQpPb3BzLCB0aGFua3MuIE5ldyBw
YXRjaCBmb3J0aGNvbWluZy4gICAgIA0KDQo=
