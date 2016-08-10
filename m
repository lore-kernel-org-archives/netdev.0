From: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Subject: Re: [PATCH net-next v11 5/6] openvswitch: add layer 3
 flow/port support
Date: Wed, 10 Aug 2016 12:16:45 +0200
Message-ID: <20160810101644.GD5451@penelope.isobedori.kobe.vergenet.net>
References: <1467827996-32547-6-git-send-email-simon.horman@netronome.com>
 <CAOrHB_BYD40ZkWbU0dvhPOCcaCVgooksOUkejxyFoagyoiBTNw@mail.gmail.com>
 <20160713073152.GC29661@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_A1ri6fouFH0H4KpEqg1icCmz+U1tcgn-5BoryX5pb1gw@mail.gmail.com>
 <20160718045025.GA2490@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_C3Hq-V4uPWLELSc2VMywjYSnKiFJ4VJQDnPpCu7s1Xkw@mail.gmail.com>
 <20160720000243.GA4688@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_CUPCfAPKfoco9GghiAZ=QyEqxpd90uo3NvEtG9STXMVA@mail.gmail.com>
 <20160808151716.GA8477@penelope.isobedori.kobe.vergenet.net>
 <20160808172839.2cc42c61@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160808172839.2cc42c61@griffin>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

T24gTW9uLCBBdWcgMDgsIDIwMTYgYXQgMDU6Mjg6MzlQTSArMDIwMCwgSmlyaSBCZW5jIHdyb3Rl
Ogo+IE9uIE1vbiwgOCBBdWcgMjAxNiAxNzoxNzoxNyArMDIwMCwgU2ltb24gSG9ybWFuIHdyb3Rl
Ogo+ID4gK2Jvb2wgc2tiX21hY19oZWFkZXJfcHJlc2VudChzdHJ1Y3Qgc2tfYnVmZiAqc2tiKQo+
ID4gK3sKPiA+ICsJcmV0dXJuIHNrYi0+ZGV2LT50eXBlID09IEFSUEhSRF9FVEhFUiB8fAo+ID4g
KwkJKHNrYi0+ZGV2LT50eXBlID09IEFSUEhSRF9OT05FICYmCj4gPiArCQkgc2tiLT5wcm90b2Nv
bCA9PSBodG9ucyhFVEhfUF9URUIpKTsKPiA+ICt9Cj4gPiArRVhQT1JUX1NZTUJPTChza2JfbWFj
X2hlYWRlcl9wcmVzZW50KTsKPiAKPiBJJ2Qgc3VnZ2VzdCBhIGRpZmZlcmVudCBuYW1lLCB0aGlz
IGxvb2tzIGxpa2UgaXQgaGFzIHNvbWV0aGluZyB0byBkbwo+IHdpdGggc2tiLT5tYWNfaGVhZGVy
LCB3aGljaCBpdCBkb2Vzbid0LiBza2JfZXRoX2hlYWRlcl9wcmVzZW50LCBwZXJoYXBzPwoKSSBz
dHJ1Z2dsZWQgdG8gY29tZSB1cCB3aXRoIGEgcmVhc29uYWJsZSBuYW1lIGFuZCBJIGRvIGxpa2Ug
eW91cgpzdWdnZXN0aW9uIGJldHRlciB0aGFuIG1pbmUuIEknbGwgdXBkYXRlIHRoZSBjb2RlIGFz
IHlvdSBzdWdnZXN0IHVubGVzcyBhCmJldHRlciBuYW1lIGVtZXJnZXMuCl9fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9w
ZW52c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2
Cg==
