From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v9 net-next 5/7] openvswitch: add layer 3
 support to ovs_packet_cmd_execute()
Date: Tue, 17 May 2016 16:51:08 +0200
Message-ID: <20160517165108.2f24054e@griffin>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
 <1462347393-22354-6-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1462347393-22354-6-git-send-email-simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
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

T24gV2VkLCAgNCBNYXkgMjAxNiAxNjozNjozMSArMDkwMCwgU2ltb24gSG9ybWFuIHdyb3RlOgo+
ICsJLyogUGFja2V0cyBmcm9tIHVzZXIgc3BhY2UgZm9yIGV4ZWN1dGlvbiBvbmx5IGhhdmUgbWV0
YWRhdGEga2V5Cj4gKwkgKiBhdHRyaWJ1dGVzLiAgT1ZTX0tFWV9BVFRSX1BBQ0tFVF9FVEhFUlRZ
UEUgaXMgdGhlbiB1c2VkIHRvIHNwZWNpZnkKPiArCSAqIHRoZSBzdGFydGluZyBsYXllciBvZiB0
aGUgcGFja2V0LiAgUGFja2V0cyB3aXRoIEV0aGVybmV0IGhlYWRlcnMKPiArCSAqIGhhdmUgdGhp
cyBhdHRyaWJ1dGUgc2V0IHRvIDAKPiArCSAqLwo+ICsJaWYgKCphdHRycyAmICgxVUxMIDw8IE9W
U19LRVlfQVRUUl9QQUNLRVRfRVRIRVJUWVBFKSkgewo+ICsJCV9fYmUxNiBldGhfdHlwZTsKPiAr
Cj4gKwkJaWYgKGlzX21hc2spIHsKPiArCQkJLyogQWx3YXlzIGV4YWN0IG1hdGNoIHBhY2tldCBF
dGhlclR5cGUgKi8KPiArCQkJZXRoX3R5cGUgPSBodG9ucygweGZmZmYpOwo+ICsJCX0gZWxzZSB7
Cj4gKwkJCWV0aF90eXBlID0gbmxhX2dldF9iZTE2KGFbT1ZTX0tFWV9BVFRSX1BBQ0tFVF9FVEhF
UlRZUEVdKTsKPiArCQkJaXNfbGF5ZXIzID0gKChldGhfdHlwZSA9PSBodG9ucyhFVEhfUF9JUCkp
IHx8Cj4gKwkJCQkgICAgIChldGhfdHlwZSA9PSBodG9ucyhFVEhfUF9JUFY2KSkpOwoKVW5rbm93
biB0eXBlcyBuZWVkIHRvIGJlIHJlamVjdGVkLCBub3QgdHJlYXRlZCBhcyBsYXllcjIsIG90aGVy
d2lzZSB3ZQptYXkgcnVuIGludG8gcHJvYmxlbXMgbGF0ZXIgKHdpdGggY29tYmluYXRpb24gb2Yg
dGhpcyBrZXJuZWwgKyBuZXdlcgp1c2VyIHNwYWNlKSB3aGVuIHdlIGFkZCBtb3JlIHR5cGVzLCBz
dWNoIGFzIEVUSF9QX05TSC4KCiBKaXJpCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9yZwpodHRw
Oi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
