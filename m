From: pravin shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH v2 2/2] openvswitch: use percpu flow stats
Date: Sat, 17 Sep 2016 19:07:30 -0700
Message-ID: <CAOrHB_Dus4NmhGEaN=i5pnvKDY0aTvgMFL19K7gF9pdsLAp4xw@mail.gmail.com>
References: <1473977513-7617-1-git-send-email-cascardo@redhat.com>
 <1473977513-7617-2-git-send-email-cascardo@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Thadeu Lima de Souza Cascardo <cascardo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1473977513-7617-2-git-send-email-cascardo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

T24gVGh1LCBTZXAgMTUsIDIwMTYgYXQgMzoxMSBQTSwgVGhhZGV1IExpbWEgZGUgU291emEgQ2Fz
Y2FyZG8KPGNhc2NhcmRvQHJlZGhhdC5jb20+IHdyb3RlOgo+IEluc3RlYWQgb2YgdXNpbmcgZmxv
dyBzdGF0cyBwZXIgTlVNQSBub2RlLCB1c2UgaXQgcGVyIENQVS4gV2hlbiB1c2luZwo+IG1lZ2Fm
bG93cywgdGhlIHN0YXRzIGxvY2sgY2FuIGJlIGEgYm90dGxlbmVjayBpbiBzY2FsYWJpbGl0eS4K
Pgo+IE9uIGEgRTUtMjY5MCAxMi1jb3JlIHN5c3RlbSwgdXN1YWwgdGhyb3VnaHB1dCB3ZW50IGZy
b20gfjRNcHBzIHRvCj4gfjE1TXBwcyB3aGVuIGZvcndhcmRpbmcgYmV0d2VlbiB0d28gNDBHYkUg
cG9ydHMgd2l0aCBhIHNpbmdsZSBmbG93Cj4gY29uZmlndXJlZCBvbiB0aGUgZGF0YXBhdGguCj4K
PiBUaGlzIGhhcyBiZWVuIHRlc3RlZCBvbiBhIHN5c3RlbSB3aXRoIHBvc3NpYmxlIENQVXMgMC03
LDE2LTIzLiBBZnRlcgo+IG1vZHVsZSByZW1vdmFsLCB0aGVyZSB3ZXJlIG5vIGNvcnJ1cHRpb24g
b24gdGhlIHNsYWIgY2FjaGUuCj4KPiBTaWduZWQtb2ZmLWJ5OiBUaGFkZXUgTGltYSBkZSBTb3V6
YSBDYXNjYXJkbyA8Y2FzY2FyZG9AcmVkaGF0LmNvbT4KPiBDYzogcHJhdmluIHNoZWxhciA8cHNo
ZWxhckBvdm4ub3JnPgoKTG9va3MgZ29vZC4KCkFja2VkLWJ5OiBQcmF2aW4gQiBTaGVsYXIgPHBz
aGVsYXJAb3ZuLm9yZz4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX18KZGV2IG1haWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0Y2gub3JnCmh0dHA6Ly9vcGVudnN3
aXRjaC5vcmcvbWFpbG1hbi9saXN0aW5mby9kZXYK
