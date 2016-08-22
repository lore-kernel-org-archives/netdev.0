From: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>
Subject: [PATCH v05 38/72] include/uapi/linux/openvswitch.h: use
	__u32 from linux/types.h
Date: Mon, 22 Aug 2016 20:32:55 +0200
Message-ID: <1471890809-4383-39-git-send-email-mikko.rapeli@iki.fi>
References: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1471890809-4383-1-git-send-email-mikko.rapeli-X3B1VOXEql0@public.gmane.org>
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

Rml4ZXMgdXNlcnNwYWNlIGNvbXBpbGVyIGVycm9yOgoKZXJyb3I6IHVua25vd24gdHlwZSBuYW1l
IOKAmHVpbnQzMl904oCZCgpTaWduZWQtb2ZmLWJ5OiBNaWtrbyBSYXBlbGkgPG1pa2tvLnJhcGVs
aUBpa2kuZmk+Ci0tLQogaW5jbHVkZS91YXBpL2xpbnV4L29wZW52c3dpdGNoLmggfCA0ICsrLS0K
IDEgZmlsZSBjaGFuZ2VkLCAyIGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pCgpkaWZmIC0t
Z2l0IGEvaW5jbHVkZS91YXBpL2xpbnV4L29wZW52c3dpdGNoLmggYi9pbmNsdWRlL3VhcGkvbGlu
dXgvb3BlbnZzd2l0Y2guaAppbmRleCBkOTVhMzAxLi42NDU0OTlhIDEwMDY0NAotLS0gYS9pbmNs
dWRlL3VhcGkvbGludXgvb3BlbnZzd2l0Y2guaAorKysgYi9pbmNsdWRlL3VhcGkvbGludXgvb3Bl
bnZzd2l0Y2guaApAQCAtNjMyLDggKzYzMiw4IEBAIGVudW0gb3ZzX2hhc2hfYWxnIHsKICAqIEBo
YXNoX2Jhc2lzOiBiYXNpcyB1c2VkIGZvciBjb21wdXRpbmcgaGFzaC4KICAqLwogc3RydWN0IG92
c19hY3Rpb25faGFzaCB7Ci0JdWludDMyX3QgIGhhc2hfYWxnOyAgICAgLyogT25lIG9mIG92c19o
YXNoX2FsZy4gKi8KLQl1aW50MzJfdCAgaGFzaF9iYXNpczsKKwlfX3UzMiAgaGFzaF9hbGc7ICAg
ICAvKiBPbmUgb2Ygb3ZzX2hhc2hfYWxnLiAqLworCV9fdTMyICBoYXNoX2Jhc2lzOwogfTsKIAog
LyoqCi0tIAoyLjguMQoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX18KZGV2IG1haWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0Y2gub3JnCmh0dHA6Ly9vcGVudnN3
aXRjaC5vcmcvbWFpbG1hbi9saXN0aW5mby9kZXYK
