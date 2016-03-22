From: =?utf-8?Q?Toke_H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>
Subject: Re: [RFCv2 0/3] mac80211: implement fq codel
Date: Tue, 22 Mar 2016 10:51:12 +0100
Message-ID: <8737rirgbz.fsf@toke.dk>
References: <CAA93jw5AAWua23TbQHZX47XcFLEqU6T=NpxuLqa6FiffBf91Fw@mail.gmail.com>
 <CA+BoTQ=hgkm2AwMb=kinx+Ezf3vjduCKNH4LNRcV_goDWH4_Vg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Network Development <netdev@vger.kernel.org>,
 linux-wireless <linux-wireless@vger.kernel.org>,
 "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>,
 Jasmine Strong <jas@eero.com>,
 "codel@lists.bufferbloat.net" <codel@lists.bufferbloat.net>,
 make-wifi-fast@lists.bufferbloat.net
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <CA+BoTQ=hgkm2AwMb=kinx+Ezf3vjduCKNH4LNRcV_goDWH4_Vg@mail.gmail.com>
 (Michal Kazior's message of "Tue, 22 Mar 2016 09:05:32 +0100")
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
 <mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
 <mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Errors-To: codel-bounces@lists.bufferbloat.net
Sender: "Codel" <codel-bounces@lists.bufferbloat.net>
List-Id: netdev.vger.kernel.org

TWljaGFsIEthemlvciA8bWljaGFsLmthemlvckB0aWV0by5jb20+IHdyaXRlczoKCj4gdHJhZmZp
Yy1nZW4gZ2VuZXJhdGVzIG9ubHkgQkUgdHJhZmZpYy4gRXZlcnl0aGluZyBlbHNlIHJ1bnMgVURQ
X1JSCj4gd2hpY2ggZG9lc24ndCBnZW5lcmF0ZSBhIGxvdCBvZiB0cmFmZmljLgoKR29vZCBwb2lu
dC4gRml4ZWQgdGhhdDogdGhlIG5ld2VzdCBnaXQgdmVyc2lvbiBvZiB0cmFmZmljLWdlbiBzdXBw
b3J0cyBhCi10IHBhcmFtZXRlciB3aGljaCB3aWxsIGJlIHNldCBhcyB0aGUgVE9TIGJ5dGUgb24g
b3V0Z29pbmcgdHJhZmZpYwoobGl0ZXJhbDsgbm8gc21hcnQgZGlmZnNlcnYgaGFuZGxpbmcsIHNv
IHlvdSBjYW4gb3ZlcnJpZGUgdGhlIEVDTiBiaXRzCmFzIHdlbGwpLgoKQWRkZWQgc3VwcG9ydCBm
b3IgYSBidXJzdC10b3MgdGVzdCBwYXJhbWV0ZXIgaW4gdGhlIEZsZW50IGJ1cnN0IHRlc3QKY29u
ZmlncyB3aGljaCB3aWxsIHVzZSB0aGlzIG5ldyBwYXJhbWV0ZXIgaWYgc2V0LgoKLVRva2UKX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQ29kZWwgbWFpbGlu
ZyBsaXN0CkNvZGVsQGxpc3RzLmJ1ZmZlcmJsb2F0Lm5ldApodHRwczovL2xpc3RzLmJ1ZmZlcmJs
b2F0Lm5ldC9saXN0aW5mby9jb2RlbAo=
