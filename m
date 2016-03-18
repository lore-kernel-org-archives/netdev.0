From: kbuild test robot <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC PATCH linux-next] ovs: internal_set_rx_headroom()
	can be static
Date: Sat, 19 Mar 2016 00:54:50 +0800
Message-ID: <20160318165450.GA16372@cairo>
References: <201603190023.RJCVrbEg%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kbuild-all-JC7UmRfGjtg@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201603190023.RJCVrbEg%fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
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

ClNpZ25lZC1vZmYtYnk6IEZlbmdndWFuZyBXdSA8ZmVuZ2d1YW5nLnd1QGludGVsLmNvbT4KLS0t
CiB2cG9ydC1pbnRlcm5hbF9kZXYuYyB8ICAgIDIgKy0KIDEgZmlsZSBjaGFuZ2VkLCAxIGluc2Vy
dGlvbigrKSwgMSBkZWxldGlvbigtKQoKZGlmZiAtLWdpdCBhL25ldC9vcGVudnN3aXRjaC92cG9y
dC1pbnRlcm5hbF9kZXYuYyBiL25ldC9vcGVudnN3aXRjaC92cG9ydC1pbnRlcm5hbF9kZXYuYwpp
bmRleCA4M2E1NTM0Li43YzhiOTBiIDEwMDY0NAotLS0gYS9uZXQvb3BlbnZzd2l0Y2gvdnBvcnQt
aW50ZXJuYWxfZGV2LmMKKysrIGIvbmV0L29wZW52c3dpdGNoL3Zwb3J0LWludGVybmFsX2Rldi5j
CkBAIC0xMzgsNyArMTM4LDcgQEAgaW50ZXJuYWxfZ2V0X3N0YXRzKHN0cnVjdCBuZXRfZGV2aWNl
ICpkZXYsIHN0cnVjdCBydG5sX2xpbmtfc3RhdHM2NCAqc3RhdHMpCiAJcmV0dXJuIHN0YXRzOwog
fQogCi12b2lkIGludGVybmFsX3NldF9yeF9oZWFkcm9vbShzdHJ1Y3QgbmV0X2RldmljZSAqZGV2
LCBpbnQgbmV3X2hyKQorc3RhdGljIHZvaWQgaW50ZXJuYWxfc2V0X3J4X2hlYWRyb29tKHN0cnVj
dCBuZXRfZGV2aWNlICpkZXYsIGludCBuZXdfaHIpCiB7CiAJZGV2LT5uZWVkZWRfaGVhZHJvb20g
PSBuZXdfaHI7CiB9Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZzd2l0
Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
