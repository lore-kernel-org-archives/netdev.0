From: kbuild test robot <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [linux-next:master 8604/12950]
 net/openvswitch/vport-internal_dev.c:141:6: sparse: symbol
 'internal_set_rx_headroom' was not declared. Should it be static?
Date: Sat, 19 Mar 2016 00:54:50 +0800
Message-ID: <201603190023.RJCVrbEg%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kbuild-all-JC7UmRfGjtg@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
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

dHJlZTogICBodHRwczovL2dpdC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC9u
ZXh0L2xpbnV4LW5leHQuZ2l0IG1hc3RlcgpoZWFkOiAgIDVlMzQ5N2NjYTI4MTYxNmU3OTMwYjc0
YTAwNzZiNzMyNGRjYzIwNTcKY29tbWl0OiAzYTkyN2JjN2NmOWQwZmJlOGY0YTgxODlkZDVmODQ0
MDIyOGY2NGU3IFs4NjA0LzEyOTUwXSBvdnM6IHByb3BhZ2F0ZSBwZXIgZHAgbWF4IGhlYWRyb29t
IHRvIGFsbCB2cG9ydHMKcmVwcm9kdWNlOgogICAgICAgICMgYXB0LWdldCBpbnN0YWxsIHNwYXJz
ZQogICAgICAgIGdpdCBjaGVja291dCAzYTkyN2JjN2NmOWQwZmJlOGY0YTgxODlkZDVmODQ0MDIy
OGY2NGU3CiAgICAgICAgbWFrZSBBUkNIPXg4Nl82NCBhbGxtb2Rjb25maWcKICAgICAgICBtYWtl
IEM9MSBDRj0tRF9fQ0hFQ0tfRU5ESUFOX18KCgpzcGFyc2Ugd2FybmluZ3M6IChuZXcgb25lcyBw
cmVmaXhlZCBieSA+PikKCj4+IG5ldC9vcGVudnN3aXRjaC92cG9ydC1pbnRlcm5hbF9kZXYuYzox
NDE6Njogc3BhcnNlOiBzeW1ib2wgJ2ludGVybmFsX3NldF9yeF9oZWFkcm9vbScgd2FzIG5vdCBk
ZWNsYXJlZC4gU2hvdWxkIGl0IGJlIHN0YXRpYz8KClBsZWFzZSByZXZpZXcgYW5kIHBvc3NpYmx5
IGZvbGQgdGhlIGZvbGxvd3VwIHBhdGNoLgoKLS0tCjAtREFZIGtlcm5lbCB0ZXN0IGluZnJhc3Ry
dWN0dXJlICAgICAgICAgICAgICAgIE9wZW4gU291cmNlIFRlY2hub2xvZ3kgQ2VudGVyCmh0dHBz
Oi8vbGlzdHMuMDEub3JnL3BpcGVybWFpbC9rYnVpbGQtYWxsICAgICAgICAgICAgICAgICAgIElu
dGVsIENvcnBvcmF0aW9uCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZz
d2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
