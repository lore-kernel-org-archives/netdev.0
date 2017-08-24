From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [PATCH net] bpf: fix bpf_setsockopts return value
Date: Thu, 24 Aug 2017 23:45:22 +0000
Message-ID: <26CD0A38-4AC2-4D37-90A2-D4AEDEBC91FA@fb.com>
References: <20170824224821.31672-1-ycheng@google.com>
 <599F6323.2000107@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "ncardwell@google.com" <ncardwell@google.com>,
        "cgallek@google.com" <cgallek@google.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Yuchung Cheng <ycheng@google.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:46661 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753411AbdHXXpo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 19:45:44 -0400
In-Reply-To: <599F6323.2000107@iogearbox.net>
Content-Language: en-US
Content-ID: <23E299D36BB5BE4793EB3B32C8E704B6@namprd15.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCk9uIDgvMjQvMTcsIDQ6MzcgUE0sICJEYW5pZWwgQm9ya21hbm4iIDxkYW5pZWxAaW9nZWFy
Ym94Lm5ldD4gd3JvdGU6DQoNCiAgICBPbiAwOC8yNS8yMDE3IDEyOjQ4IEFNLCBZdWNodW5nIENo
ZW5nIHdyb3RlOg0KICAgID4gVGhpcyBwYXRjaCBmaXhlcyBhIGJ1ZyBjYXVzaW5nIGFueSBzb2Nr
IG9wZXJhdGlvbnMgdG8gYWx3YXlzIHJldHVybiBFSU5WQUwuDQogICAgPg0KICAgID4gRml4ZXM6
IGE1MTkyYzUyMzc3ZSAoImJwZjogZml4IHRvIGJwZl9zZXRzb2Nrb3BzIikuDQogICAgPiBSZXBv
cnRlZC1ieTogTmVhbCBDYXJkd2VsbCA8bmNhcmR3ZWxsQGdvb2dsZS5jb20+DQogICAgPiBTaWdu
ZWQtb2ZmLWJ5OiBZdWNodW5nIENoZW5nIDx5Y2hlbmdAZ29vZ2xlLmNvbT4NCiAgICA+IEFja2Vk
LWJ5OiBOZWFsIENhcmR3ZWxsIDxuY2FyZHdlbGxAZ29vZ2xlLmNvbT4NCiAgICA+IEFja2VkLWJ5
OiBDcmFpZyBHYWxsZWsgPGtyYWlnQGdvb2dsZS5jb20+DQogICAgDQogICAgT2hoIHdlbGwsIHRo
YW5rcyBmb3IgdGhlIGZpeCENCiAgICANCiAgICBBY2tlZC1ieTogRGFuaWVsIEJvcmttYW5uIDxk
YW5pZWxAaW9nZWFyYm94Lm5ldD4NCg0KVGhhbmtzISBJIG5ldmVyIGNoZWNrZWQgcmV0dXJuIHZh
bHVlcyBpbiBieSBicGYgdGVzdCBwcm9ncmFtcw0KDQpBY2tlZC1ieTogTGF3cmVuY2UgQnJha21v
IDxicmFrbW9AZmIuY29tPiANCiAgIA0KDQo=
