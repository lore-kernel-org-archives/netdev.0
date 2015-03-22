From: =?koi8-r?B?8MHOz9cg4c7E0sXK?= <rockford@yandex.ru>
Subject: Re: Bug in drivers/net/ethernet/freescale/fec_main.c,
 TX is broken. In 4.0.0-rc3
Date: Sun, 22 Mar 2015 23:08:01 +0300
Message-ID: <8321261427054881@web25h.yandex.ru>
References: <390621425930628@web28o.yandex.ru>
 <3625951426018334@web26j.yandex.ru>
 <BLUPR03MB373A446E2D97992CA7AAA32F5020@BLUPR03MB373.namprd03.prod.outlook.com>
 <726281426513068@web10o.yandex.ru>
 <BLUPR03MB3739B9C6E14A106CCAEBA32F5020@BLUPR03MB373.namprd03.prod.outlook.com>
 <994171426532944@web7m.yandex.ru>
 <20150321205359.GM8656@n2100.arm.linux.org.uk>
 <CAOMZO5BnPQTFoBRr4EGH24_yZZAY6NJmVFg4WeiJcTqrYqki5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Content-Transfer-Encoding: base64
Cc: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Fabio Estevam <festevam@gmail.com>,
 Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAOMZO5BnPQTFoBRr4EGH24_yZZAY6NJmVFg4WeiJcTqrYqki5A@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

SGkhCgoyMi4wMy4yMDE1LCAwMTozNSwgIkZhYmlvIEVzdGV2YW0iIDxmZXN0ZXZhbUBnbWFpbC5j
b20+Ogo+IEhpIFJ1c3NlbGwsCj4KPiBPbiBTYXQsIE1hciAyMSwgMjAxNSBhdCA1OjUzIFBNLCBS
dXNzZWxsIEtpbmcgLSBBUk0gTGludXgKPiA8bGludXhAYXJtLmxpbnV4Lm9yZy51az4gd3JvdGU6
Cj4+IJpHaXZlbiB0aGF0IHRoaXMgYnVnIGNhbiBzZXJpb3VzbHkgc2NyZXcgZGF0YSB1cCBpbiB1
bmRldGVjdGFibGUgd2F5cyAoVENQCj4+IJpjaGVja3N1bXMgZG9uJ3Qgc2F2ZSB5b3UsIGJlY2F1
c2UgdGhlIEZFQyBnZW5lcmF0ZXMgdGhlbSBvbiB0aGUgZGF0YSB3aGljaAo+PiCaaXQgcmVhZCBm
cm9tIG1lbW9yeSwgZXZlbiBpZiBpdCBoYXBwZW5lZCB0byByZWFkIHRoZSBkYXRhIGZyb20gdGhl
IFNvQydzCj4+IJpib290IFJPTSkgd2UgZG8gbmVlZCB0byBnZXQgdGhpcyBmaXhlZCBBU0FQLgo+
Cj4gQ3VycmVudCBtYWlubGluZSBoYXMgMmI5OTVmNjM5ODcwMTMgcmV2ZXJ0ZWQsIHNvIDQuMC1y
YzUgd2lsbCBub3QgaGF2ZQo+IHRoaXMgY29ycnVwdGlvbiBwcm9ibGVtLgoKSSd2ZSB0ZXN0ZWQg
d2l0aCBjdXJyZW50IG1haW5saW5lIGFuZCB3aXRoIG1haW5saW5lKzJiOTk1ZjYzOTg3MDEzIGNv
bW1pdCB3aXRoIFJ1c3NlbGwncwpmaXggYW5kIGl0IGJvdGggd29ya3MgZmluZSwgd2l0aG91dCBj
b3JydXB0aW9uLgoKLS0KIOHOxNLFygoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX18KbGludXgtYXJtLWtlcm5lbCBtYWlsaW5nIGxpc3QKbGludXgtYXJtLWtl
cm5lbEBsaXN0cy5pbmZyYWRlYWQub3JnCmh0dHA6Ly9saXN0cy5pbmZyYWRlYWQub3JnL21haWxt
YW4vbGlzdGluZm8vbGludXgtYXJtLWtlcm5lbAo=
