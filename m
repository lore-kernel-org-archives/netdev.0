From: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 2/3] tests: Enable debugging in pyftpdlib.
Date: Tue, 20 Oct 2015 15:23:59 -0700
Message-ID: <1445379840-113042-2-git-send-email-jrajahalme@nicira.com>
References: <1445379840-113042-1-git-send-email-jrajahalme@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1445379840-113042-1-git-send-email-jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

SGVscHMgZGlhZ25vc2luZyBwcm9ibGVtcy4KClNpZ25lZC1vZmYtYnk6IEphcm5vIFJhamFoYWxt
ZSA8anJhamFoYWxtZUBuaWNpcmEuY29tPgotLS0KIHRlc3RzL3Rlc3QtbDcucHkgfCA0ICsrKysK
IDEgZmlsZSBjaGFuZ2VkLCA0IGluc2VydGlvbnMoKykKCmRpZmYgLS1naXQgYS90ZXN0cy90ZXN0
LWw3LnB5IGIvdGVzdHMvdGVzdC1sNy5weQppbmRleCA2NWM2YzJhLi5mYWVjMmJjIDEwMDc1NQot
LS0gYS90ZXN0cy90ZXN0LWw3LnB5CisrKyBiL3Rlc3RzL3Rlc3QtbDcucHkKQEAgLTMwLDYgKzMw
LDEwIEBAIGRlZiBnZXRfZnRwZCgpOgogICAgICAgICBmcm9tIHB5ZnRwZGxpYi5oYW5kbGVycyBp
bXBvcnQgRlRQSGFuZGxlcgogICAgICAgICBmcm9tIHB5ZnRwZGxpYi5zZXJ2ZXJzIGltcG9ydCBG
VFBTZXJ2ZXIKIAorICAgICAgICBpbXBvcnQgbG9nZ2luZworICAgICAgICBpbXBvcnQgcHlmdHBk
bGliLmxvZworICAgICAgICBweWZ0cGRsaWIubG9nLkxFVkVMID0gbG9nZ2luZy5ERUJVRworCiAg
ICAgICAgIGNsYXNzIE9WU0ZUUEhhbmRsZXIoRlRQSGFuZGxlcik6CiAgICAgICAgICAgICBhdXRo
b3JpemVyID0gRHVtbXlBdXRob3JpemVyKCkKICAgICAgICAgICAgIGF1dGhvcml6ZXIuYWRkX2Fu
b255bW91cygiL3RtcCIpCi0tIAoyLjEuNAoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX18KZGV2IG1haWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0Y2gub3JnCmh0
dHA6Ly9vcGVudnN3aXRjaC5vcmcvbWFpbG1hbi9saXN0aW5mby9kZXYK
