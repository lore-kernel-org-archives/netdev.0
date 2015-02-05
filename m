From: Andy Zhou <azhou-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC: add openvswitch actions using BPF 1/9] hack: Do
 not compile datapath
Date: Thu, 5 Feb 2015 11:11:09 -0800
Message-ID: <CACzMAJL9CE08Qs3BAujUZaT_XDWG_2RJi6QuGLMY0r7y3wMJjQ@mail.gmail.com>
References: <1423090163-19902-1-git-send-email-azhou@nicira.com>
 <1423090163-19902-2-git-send-email-azhou@nicira.com>
 <20150205134454.GA5546@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "dev-yBygre7rU0SM8Zsap4Y0gw@public.gmane.org" <dev-yBygre7rU0SM8Zsap4Y0gw@public.gmane.org>,
 "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Thomas Graf <tgraf-aqu+mcpWfvtqO0yjgLDq5wC/G2K4zDHf@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20150205134454.GA5546-4EA/1caXOu0mYvmMESoHnA@public.gmane.org>
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

WWVzLiBUaGF0J3MgdGhlIHBsYW4uCgpPbiBUaHUsIEZlYiA1LCAyMDE1IGF0IDU6NDQgQU0sIFRo
b21hcyBHcmFmIDx0Z3JhZkBub2lyb25ldHdvcmtzLmNvbT4gd3JvdGU6Cj4gT24gMDIvMDQvMTUg
YXQgMDI6NDlwbSwgQW5keSBaaG91IHdyb3RlOgo+PiBUaGUgT1ZTIGVCUEYgcGF0Y2ggc2V0cyBh
cmUgZGV2ZWxvcGVkIGFnYWluc3QgbWFzdGVyICduZXQtbmV4dCcgdHJlZSwKPj4gd2hpY2ggaXMg
Y3VycmVudGx5IHRhcmdldGluZyBmb3Iga2VybmVsIHZlcnNpb24gMy4xOS4KPj4KPj4gVGhlIGRh
dGFwYXRoIGluIE9WUyBtYXRlciBkb2VzIG5vdCBjdXJyZW50bHkgc3VwcG9ydCAzLjE5IGtlcm5l
bC4KPj4gQnV0IHdlIHNob3VsZCBub3QgcmVhbGx5IHVzaW5nIE9WUyBkYXRhcGF0aCwgVGhlIGNo
YW5nZXMgaW4gdGhlCj4+IGZvbGxvdyBwYXRjaGVzIGFyZSBvbmx5IGNoYW5nZXMgaW4gdXNlciBz
cGFjZSBwcm9ncmFtcywgd2hpY2ggc2hvdWxkCj4+IHdvcmsgd2l0aCB0aGUga2VybmVsIG1vZHVs
ZSBidWlsdCBmcm9tIHRoZSAnbmV0LW5leHQnIHRyZWUuCj4+Cj4+IFRoaXMgcGF0Y2ggZGlzYWJs
ZXMgYnVpbGRpbmcgb2YgdGhlIGRhdGFwYXRoIGFuZCBkaXNhYmxlcyB0aGUKPj4gY29uZmlndXJh
dGlvbiB0aW1lIGtlcm5lbCB2ZXJzaW9uIGNoZWNrLgo+Pgo+PiBTaWduZWQtb2ZmLWJ5OiBBbmR5
IFpob3UgPGF6aG91QG5pY2lyYS5jb20+Cj4KPiBZb3UgY2FuIGRyb3AgdGhpcyB3aGVuIHRoZSBk
YXRhcGF0aCBzeW5jIHNlcmllcyBpcyBmdWxseSBtZXJnZWQuCl9fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dp
dGNoLm9yZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
