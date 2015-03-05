From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: OVS Offload Decision Proposal
Date: Thu, 05 Mar 2015 14:21:57 -0500 (EST)
Message-ID: <20150305.142157.803216605925013984.davem@davemloft.net>
References: <54F86D9E.7000200@gmail.com>
 <CAN+pFwJ6XoCghw9uHb5UA88o8zoXqGNhEnVHPQWrOV1p=O-15Q@mail.gmail.com>
 <CAN+pFw+LDAiebOzFF+DD81vJp7y0OfVg=5BE0m47B2ZUp6zpeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org, john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
 therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
To: marichika4-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAN+pFw+LDAiebOzFF+DD81vJp7y0OfVg=5BE0m47B2ZUp6zpeQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

CkkgZmluZCBpdCBmdW5ueSB0aGF0IHdlIGhhdmVuJ3QgZXZlbiBnb3QgYSBMMyBmb3J3YXJkaW5n
CmltcGxlbWVudGF0aW9uIGZsZXNoZWQgb3V0IGVub3VnaCB0byBtZXJnZSBpbnRvIHRoZSB0cmVl
LCBhbmQgcGVvcGxlCmFyZSB0YWxraW5nIGFib3V0IFZPSVAgdG8gVkxBTiBjbGFzc2lmaWNhdGlv
biwgaHcgYnVnIHdvcmthcm91bmRzLCBhbmQKc2hpdCBsaWtlIHRoYXQuCgpFdmVyeW9uZSBpcyBy
ZWFsbHkganVtcGluZyB0aGUgZ3VuIG9uIGFsbCBvZiB0aGlzLgoKTm9ib2R5IGtub3dzIHdoYXQg
d2Ugd2lsbCBuZWVkLCBhbmQgSSBkbyBtZWFuIG5vYm9keS4gIE5vdCBtZSwgbm90CnN3aXRjaCBo
YXJkd2FyZSBndXlzLCBub3QgcGVvcGxlIHdvcmtpbmcgb24gdGhlIGNvZGUgYWN0aXZlbHkgcmln
aHQKbm93LiAgTm9ib2R5LgoKVGhlIG9ubHkgd2F5IHRvIGZpbmQgb3V0IGlzIHRvIF9kb18sIGlu
IHNtYWxsIGluY3JlbWVudGFsIHN0ZXBzLApyYXRoZXIgdGhhbiBiaWcgcmV2b2x1dGlvbmFyeSBj
aGFuZ2VzLgoKU2ltcGxpZnksIGNvbnNvbGlkYXRlLCBhbmQgb3B0aW1pemUgbGF0ZXIuCgpMZXQn
cyBnZXQgc29tZXRoaW5nIHRoYXQgd29ya3MgZm9yIGF0IGxlYXN0IHRoZSBzaW1wbGVzdCBjYXNl
cyBmaXJzdC4KV2UgZG9uJ3QgZXZlbiBoYXZlIHRoYXQgeWV0LgoKU28gaWYgcGVvcGxlIGNvdWxk
IGRyaXZlIHRoZWlyIGF0dGVudGlvbiB0b3dhcmRzIFNjb3R0J3MgTDMgZm9yd2FyZGluZwp3b3Jr
IGluc3RlYWQgb2YgdGhpcyBmbG93IGNyYXAgd2hpY2ggaXMgdG9vIGZhciBpbnRvIHRoZSBob3Jp
em9uIHRvCmV2ZW4gYmUgcHJvcGVybHkgc2VlbiB5ZXQsIEknZCBfcmVhbGx5XyBhcHByZWNpYXRl
IGl0LgoKVGhhbmtzLgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dp
dGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
