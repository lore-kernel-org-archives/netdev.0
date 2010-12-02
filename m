From: Nick Kossifidis <mickflemm@gmail.com>
Subject: Re: [PATCH 2/2] ath: Fix logging message typos
Date: Thu, 2 Dec 2010 08:01:26 +0200
Message-ID: <AANLkTimimyhHT2=xT1T8vJ=3WZB4h85ur=yvEfT2Wv-p@mail.gmail.com>
References: <276469c602c402565b49f99521ea19757429e81e.1291266731.git.joe@perches.com>
	<a345e995a816576a4c2c39aec43716c18011475b.1291266731.git.joe@perches.com>
	<20101202053055.19479.qmail@stuge.se>
	<1291268087.1761.3.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-wireless@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>,
	netdev@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	Bob Copeland <me@bobcopeland.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jouni Malinen <jmalinen@atheros.com>,
	Senthil Balasubramanian <senthilkumar@atheros.com>,
	ath9k-devel@lists.ath9k.org,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
	Peter Stuge <peter@stuge.se>, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <1291268087.1761.3.camel@Joe-Laptop>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

MjAxMC8xMi8yIEpvZSBQZXJjaGVzIDxqb2VAcGVyY2hlcy5jb20+Ogo+IE9uIFRodSwgMjAxMC0x
Mi0wMiBhdCAwNjozMCArMDEwMCwgUGV0ZXIgU3R1Z2Ugd3JvdGU6Cj4+IEpvZSBQZXJjaGVzIHdy
b3RlOgo+PiA+ICsrKyBiL2RyaXZlcnMvbmV0L3dpcmVsZXNzL2F0aC9hdGg5ay9hcjkwMDJfY2Fs
aWIuYwo+PiAuLgo+PiA+IEBAIC03MzQsNyArNzM0LDcgQEAgc3RhdGljIGJvb2wgYXI5Mjg1X2h3
X2NsX2NhbChzdHJ1Y3QgYXRoX2h3ICphaCwgc3RydWN0IGF0aDlrX2NoYW5uZWwgKmNoYW4pCj4+
ID4gwqAgwqAgaWYgKCFhdGg5a19od193YWl0KGFoLCBBUl9QSFlfQUdDX0NPTlRST0wsIEFSX1BI
WV9BR0NfQ09OVFJPTF9DQUwsCj4+ID4gwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
MCwgQUhfV0FJVF9USU1FT1VUKSkgewo+PiA+IMKgIMKgIMKgIMKgIMKgIMKgIGF0aF9kYmcoY29t
bW9uLCBBVEhfREJHX0NBTElCUkFURSwKPj4gPiAtIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
ICJvZmZzZXQgY2FsaWJyYXRpb24gZmFpbGVkIHRvIGNvbXBsZXRlIGluIDFtczsgbm9pc3kgPz9c
biIpOwo+PiA+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgIm9mZnNldCBjYWxpYnJhdGlv
biBmYWlsZWQgdG8gY29tcGxldGUgaW4gMW1zOyBub2lzeSBlbmZpcm9ubWVudD9cbiIpOwo+Pgo+
PiBlbmZpcm9ubWVudD8gOikKPgo+IFVtbSwgd2hhdCdzIGEgdHlwbyBmaXggcGF0Y2ggd2l0aG91
dCBtb3JlIHR5cG9zPwo+IENvcnJlY3Q/IMKgSG93IGR1bGwuLi4KPgo+PiA+IMKgIMKgIGF0aF9k
YmcoY29tbW9uLCBBVEhfREJHX0FOSSwKPj4gPiAtIMKgIMKgIMKgIMKgIMKgICJHZXR0aW5nIHNw
dXIgaWR4ICVkIGlzMkdoei4gJWQgdmFsICV4XG4iLAo+PiA+ICsgwqAgwqAgwqAgwqAgwqAgIkdl
dHRpbmcgc3B1ciBpZHg6JWQgaXMyR2h6OiVkIHZhbDoleFxuIiwKPj4gPiDCoCDCoCDCoCDCoCDC
oCDCoCBpLCBpczJHSHosIGFoLT5jb25maWcuc3B1cmNoYW5zW2ldW2lzMkdIel0pOwo+Pgo+PiBJ
cyB0aGlzIHNob3J0IGZvciAic3B1cmlvdXMiID8KPgo+IExpa2VseS4gwqBBbnlvbmUgd2FudCB0
byBjaGFuZ2UgaXQgdG8gYSB3aG9sZSB3b3JkPwo+Cj4KCk5vcGUgaXQgc3RhbmRzIGZvciBzcHVy
IG5vaXNlIChoYXJtb25pY3MpCmh0dHA6Ly93d3cucGF0ZW50Z2VuaXVzLmNvbS9wYXRlbnQvNzgz
NTQ1Ni5odG1sCgooSSBoYXZlIHRvIGFkZCB0aGF0IGxpbmsgdG8gdGhlIGNvbW1lbnRzLCBpdCdz
IG5ldyA7LSkpCgotLSAKR1BHIElEOiAweEQyMURCMkRCCkFzIHlvdSByZWFkIHRoaXMgcG9zdCBn
bG9iYWwgZW50cm9weSByaXNlcy4gSGF2ZSBGdW4gOy0pCk5pY2sKX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX18KYXRoOWstZGV2ZWwgbWFpbGluZyBsaXN0CmF0
aDlrLWRldmVsQGxpc3RzLmF0aDlrLm9yZwpodHRwczovL2xpc3RzLmF0aDlrLm9yZy9tYWlsbWFu
L2xpc3RpbmZvL2F0aDlrLWRldmVsCg==
