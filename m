From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 0/3 net-next] Lockless netlink_lookup()
 with new concurrent hash table
Date: Thu, 31 Jul 2014 22:46:59 -0700 (PDT)
Message-ID: <20140731.224659.1839149761075616147.davem@davemloft.net>
References: <cover.1406846586.git.tgraf@suug.ch>
 <20140731.223946.2222491319947824077.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso8859-7"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org,
 paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, walpole-sKt6ljEC1JY3uPMLIKxrzw@public.gmane.org
To: tgraf-G/eBtMaohhA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140731.223946.2222491319947824077.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVGh1LCAzMSBK
dWwgMjAxNCAyMjozOTo0NiAtMDcwMCAoUERUKQ0KDQo+IExvb2tzIGdyZWF0LCBzZXJpZXMgYXBw
bGllZCwgdGhhbmtzIQ0KDQpBY3R1YWxseSwgdGhpcyBuZWVkcyBtb3JlIHdvcmssIHJldmVydGVk
Og0KDQpuZXQvbmV0ZmlsdGVyL25mdF9oYXNoLmM6IEluIGZ1bmN0aW9uIKFuZnRfaGFzaF9kZXN0
cm95ojoNCm5ldC9uZXRmaWx0ZXIvbmZ0X2hhc2guYzoxODM6MzogZXJyb3I6IKFodKIgdW5kZWNs
YXJlZCAoZmlyc3QgdXNlIGluIHRoaXMgZnVuY3Rpb24pDQpuZXQvbmV0ZmlsdGVyL25mdF9oYXNo
LmM6MTgzOjM6IG5vdGU6IGVhY2ggdW5kZWNsYXJlZCBpZGVudGlmaWVyIGlzIHJlcG9ydGVkIG9u
bHkgb25jZSBmb3IgZWFjaCBmdW5jdGlvbiBpdCBhcHBlYXJzIGluDQpfX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVu
dnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
