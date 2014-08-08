From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: =?UTF-8?q?=5BPATCH=202/14=5D=20net=3A=20axienet=3A=20delete=20unneeded=20test=20before=20of=5Fnode=5Fput?=
Date: Fri,  8 Aug 2014 12:07:43 +0200
Message-ID: <1407492475-26283-2-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
 linux-kernel@vger.kernel.org, Michal Simek <michal.simek@xilinx.com>,
 =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>,
 John Linn <John.Linn@xilinx.com>, linux-arm-kernel@lists.infradead.org
To: Anirudha Sarangi <anirudh@xilinx.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

RnJvbTogSnVsaWEgTGF3YWxsIDxKdWxpYS5MYXdhbGxAbGlwNi5mcj4KCk9mX25vZGVfcHV0IHN1
cHBvcnRzIE5VTEwgYXMgaXRzIGFyZ3VtZW50LCBzbyB0aGUgaW5pdGlhbCB0ZXN0IGlzIG5vdApu
ZWNlc3NhcnkuCgpTdWdnZXN0ZWQgYnkgVXdlIEtsZWluZS1Lw7ZuaWcuCgpUaGUgc2VtYW50aWMg
cGF0Y2ggdGhhdCBmaXhlcyB0aGlzIHByb2JsZW0gaXMgYXMgZm9sbG93czoKKGh0dHA6Ly9jb2Nj
aW5lbGxlLmxpcDYuZnIvKQoKLy8gPHNtcGw+CkBACmV4cHJlc3Npb24gZTsKQEAKCi1pZiAoZSkK
ICAgb2Zfbm9kZV9wdXQoZSk7Ci8vIDwvc21wbD4KClNpZ25lZC1vZmYtYnk6IEp1bGlhIExhd2Fs
bCA8SnVsaWEuTGF3YWxsQGxpcDYuZnI+CgotLS0KIGRyaXZlcnMvbmV0L2V0aGVybmV0L3hpbGlu
eC94aWxpbnhfYXhpZW5ldF9tYWluLmMgfCAgICAzICstLQogMSBmaWxlIGNoYW5nZWQsIDEgaW5z
ZXJ0aW9uKCspLCAyIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVy
bmV0L3hpbGlueC94aWxpbnhfYXhpZW5ldF9tYWluLmMgYi9kcml2ZXJzL25ldC9ldGhlcm5ldC94
aWxpbngveGlsaW54X2F4aWVuZXRfbWFpbi5jCmluZGV4IDdiMGE3MzUuLjMwZTg2MDggMTAwNjQ0
Ci0tLSBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L3hpbGlueC94aWxpbnhfYXhpZW5ldF9tYWluLmMK
KysrIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQveGlsaW54L3hpbGlueF9heGllbmV0X21haW4uYwpA
QCAtMTYzMCw4ICsxNjMwLDcgQEAgc3RhdGljIGludCBheGllbmV0X29mX3JlbW92ZShzdHJ1Y3Qg
cGxhdGZvcm1fZGV2aWNlICpvcCkKIAlheGllbmV0X21kaW9fdGVhcmRvd24obHApOwogCXVucmVn
aXN0ZXJfbmV0ZGV2KG5kZXYpOwogCi0JaWYgKGxwLT5waHlfbm9kZSkKLQkJb2Zfbm9kZV9wdXQo
bHAtPnBoeV9ub2RlKTsKKwlvZl9ub2RlX3B1dChscC0+cGh5X25vZGUpOwogCWxwLT5waHlfbm9k
ZSA9IE5VTEw7CiAKIAlpb3VubWFwKGxwLT5yZWdzKTsKCgpfX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fXwpsaW51eC1hcm0ta2VybmVsIG1haWxpbmcgbGlzdAps
aW51eC1hcm0ta2VybmVsQGxpc3RzLmluZnJhZGVhZC5vcmcKaHR0cDovL2xpc3RzLmluZnJhZGVh
ZC5vcmcvbWFpbG1hbi9saXN0aW5mby9saW51eC1hcm0ta2VybmVsCg==
