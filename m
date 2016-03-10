From: pravin shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH net-next] ovs: allow nl 'flow set' to use ufid
 without flow key
Date: Wed, 9 Mar 2016 16:32:29 -0800
Message-ID: <CAOrHB_B2QC+5dzgXjc6xDB3OLndGqKhsgRbvcML4j-JEa+=ZgA@mail.gmail.com>
References: <1457543157-5240-1-git-send-email-samuel.gauthier@6wind.com>
 <CAOrHB_DtUjG4DkmFZb+Qj1UAWsTOG3sJH0tQEknnTF-PRQCWzQ@mail.gmail.com>
 <CAMEOZhK0kBpdS8uOqYqzQs+6LyWh5K3MWL__CRoThmNRnBN2MQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Samuel Gauthier <samuel.gauthier-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAMEOZhK0kBpdS8uOqYqzQs+6LyWh5K3MWL__CRoThmNRnBN2MQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

T24gV2VkLCBNYXIgOSwgMjAxNiBhdCA0OjI1IFBNLCBTYW11ZWwgR2F1dGhpZXIKPHNhbXVlbC5n
YXV0aGllckA2d2luZC5jb20+IHdyb3RlOgo+IFNvcnJ5LCBJIG1pc3NlZCB0aGF0LiBUaGFuayB5
b3UgZm9yIHBvaW50aW5nIGl0IG91dC4KPgo+IEFsdGhvdWdoLCBzZXQgY29tbWFuZCBpcyBhbHNv
IHVzZWQgdG8gcmVzZXQgdGhlIGZsb3cgc3RhdGlzdGljcywgYW5kIHRoZQo+IGFjdGlvbiBhdHRy
aWJ1dGUgc2VlbXMgb3B0aW9uYWwuIFdvdWxkIHlvdSBmaW5kIGFjY2VwdGFibGUgdG8gbWFrZSB0
aGUga2V5Cj4gYXR0cmlidXRlIG1hbmRhdG9yeSBvbmx5IGlmIHRoZSBhY3Rpb24gYXR0cmlidXRl
IGlzIHByb3ZpZGVkPwo+Cj4gVGhlIG92cy1kcGN0bCBjb21tYW5kIGNvdWxkIHRoZW4gYmUgc2lt
cGxpZmllZCB0byBzdXBwb3J0IG92cy1kcGN0bCAtLWNsZWFyCj4gbW9kLWZsb3cgdWZpZDo8dWZp
ZD4gaW5zdGVhZCBvZiBoYXZpbmcgdG8gc3BlY2lmeSB0aGUgZmxvdyBhbmQgYWN0aW9uIHdoZW4K
PiB5b3UganVzdCB3YW50IHRvIHJlc2V0IHRoZSBzdGF0aXN0aWNzIG9mIGEgZmxvdy4KPgoKVGhh
dCBpcyBmaW5lIHdpdGggbWUuCgpUaGFua3MsClByYXZpbi4KX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX18KZGV2IG1haWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0
Y2gub3JnCmh0dHA6Ly9vcGVudnN3aXRjaC5vcmcvbWFpbG1hbi9saXN0aW5mby9kZXYK
