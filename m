From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] kmod: don't load module unless req process has
 CAP_SYS_MODULE
Date: Mon, 15 May 2017 09:48:23 -0400 (EDT)
Message-ID: <20170515.094823.1069232190223991895.davem@davemloft.net>
References: <20170512232259.10820-1-mahesh@bandewar.net>
        <20170514104537.GA29323@kroah.com>
        <CAF2d9jh6zARipRGM92drOjjrpicF6177cnUf=6oHbR9tHX1ObA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: gregkh@linuxfoundation.org, mahesh@bandewar.net, mingo@kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        ebiederm@xmission.com, keescook@chromium.org, edumazet@google.com
To: maheshb@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAF2d9jh6zARipRGM92drOjjrpicF6177cnUf=6oHbR9tHX1ObA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogTWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSw
KSA8bWFoZXNoYkBnb29nbGUuY29tPg0KRGF0ZTogU3VuLCAxNCBNYXkgMjAxNyAxOTo0MjowOCAt
MDcwMA0KDQo+IEFueSBtb2R1bGUgd2hlbiBsb2FkZWQgZ2V0cyBsb2FkZWQgc3lzdGVtLXdpZGUg
YXMgd2UgY2FuJ3QgYWxsb3cNCj4gbW9kdWxlIGxvYWRpbmcgcGVyLW5zLiBUbyB2YWxpZGF0ZSB0
aGUgYmVoYXZpb3IgSSB3YXMgY29tcGFyaW5nIGl0DQo+IHdpdGggaW5zbW9kL21vZHByb2JlLCBp
ZiB0aGF0IGRvZXNuJ3QgYWxsb3cgYmVjYXVzZSBvZiBsYWNrIG9mIHRoaXMNCj4gY2FwYWJpbGl0
eSBpbiBkZWZhdWx0LW5zLCB0aGVuIHRoaXMgKmluZGlyZWN0KiBtZXRob2Qgb2YgbG9hZGluZw0K
PiBtb2R1bGUgc2hvdWxkIG5vdCBhbGxvdyB0aGUgc2FtZSBhY3Rpb24gYW5kIHRoZSBiZWhhdmlv
ciBzaG91bGQgYmUNCj4gY29uc2lzdGVudC4gU28gd2l0aCB0aGF0IGxvZ2ljIGlmIHVzZXJzcGFj
ZSBhc2tzIGZvciBhIHJhbmRvbQ0KPiBjaGFyLWRldmljZSBpZiBpbnNtb2QvbW9kcHJvYmUgY2Fu
bm90IGxvYWQgaXQsIHRoZW4gdGhpcyBtZXRob2Qgc2hvdWxkDQo+IG5vdCBsb2FkIGl0IGVpdGhl
ciBmb3IgdGhlIGNvbnNpc3RlbmN5LCByaWdodD8NCg0KQSBsb3Qgb2YgdXMgd29ycnkgdGhhdCB0
aGUgYXJlIGRlY2FkZXMgb2YgcHJlY2VkZW5jZSBmb3IgdGhlIGN1cnJlbnQNCmJlaGF2aW9yLg0K
DQpJZiB0aGUgdXNlciBhc2tzIGZvciBicmlkZ2Ugc3RhdGlzdGljcyBhbmQgdGhlIGJyaWRnZSBt
b2R1bGUgaXNuJ3QNCmxvYWRlZCwgaXQgZG9lcyBnZXQgbG9hZGVkIGFuZCB0aGV5IHNlZSB0aGUg
c3RhdGlzdGljcy4NCg0KU2FtZSBnb2VzIGZvciBvcGVuaW5nIHNvY2tldCB0eXBlcyBvZiB2YXJp
b3VzIHByb3RvY29scy4NCg0KVGhpbmdzIHJlYWxseSBjYW4gYnJlYWsgaWYgd2Ugc3RvcCBkb2lu
ZyB0aGlzLg0K
