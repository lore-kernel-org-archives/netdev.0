From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 00/35] treewide trivial patches converting
 pr_warning to pr_warn
Date: Thu, 23 Feb 2017 09:18:24 -0800
Message-ID: <1487870304.14159.29.camel@perches.com>
References: <cover.1487314666.git.joe@perches.com>
 <CAL_JsqLTaq-QLTqfyDO8EVJYpgeUx1e4J0Fo2NvfFWqVoiVedQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>,
 linux-ia64@vger.kernel.org, SH-Linux <linux-sh@vger.kernel.org>,
 Alexander Shishkin <alexander.shishkin@linux.intel.com>,
 nouveau@lists.freedesktop.org, Linux-ALSA <alsa-devel@alsa-project.org>,
 dri-devel <dri-devel@lists.freedesktop.org>,
 virtualization@lists.linux-foundation.org,
 "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>,
 "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>,
 sparclinux@vger.kernel.org, drbd-dev@lists.linbit.com,
 linux-scsi@vger.kernel.org, Richard Weinberger <richard@nod.at>,
 sfi-devel@simplefirmware.org, amd-gfx@lists.freedesktop.org,
 "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
 tboot-devel@lists.sourceforge.net, oprofile-list@lists.sf.net,
 "linux-input@vger.kernel.org" <linux-input@vger.kernel.org>,
 xen-devel@lists.xenproject.org,
 "linux-media@vger.k
To: Rob Herring <robh@kernel.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <CAL_JsqLTaq-QLTqfyDO8EVJYpgeUx1e4J0Fo2NvfFWqVoiVedQ@mail.gmail.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

T24gVGh1LCAyMDE3LTAyLTIzIGF0IDA5OjI4IC0wNjAwLCBSb2IgSGVycmluZyB3cm90ZToKPiBP
biBGcmksIEZlYiAxNywgMjAxNyBhdCAxOjExIEFNLCBKb2UgUGVyY2hlcyA8am9lQHBlcmNoZXMu
Y29tPiB3cm90ZToKPiA+IFRoZXJlIGFyZSB+NDMwMCB1c2VzIG9mIHByX3dhcm4gYW5kIH4yNTAg
dXNlcyBvZiB0aGUgb2xkZXIKPiA+IHByX3dhcm5pbmcgaW4gdGhlIGtlcm5lbCBzb3VyY2UgdHJl
ZS4KPiA+IAo+ID4gTWFrZSB0aGUgdXNlIG9mIHByX3dhcm4gY29uc2lzdGVudCBhY3Jvc3MgYWxs
IGtlcm5lbCBmaWxlcy4KPiA+IAo+ID4gVGhpcyBleGNsdWRlcyBhbGwgZmlsZXMgaW4gdG9vbHMv
IGFzIHRoZXJlIGlzIGEgc2VwYXJhdGUKPiA+IGRlZmluZSBwcl93YXJuaW5nIGZvciB0aGF0IGRp
cmVjdG9yeSB0cmVlIGFuZCBwcl93YXJuIGlzCj4gPiBub3QgdXNlZCBpbiB0b29scy8uCj4gPiAK
PiA+IERvbmUgd2l0aCAnc2VkIHMvXGJwcl93YXJuaW5nXGIvcHJfd2Fybi8nIGFuZCBzb21lIGVt
YWNzaW5nLgpbXQo+IFdoZXJlJ3MgdGhlIHJlbW92YWwgb2YgcHJfd2FybmluZyBzbyB3ZSBkb24n
dCBoYXZlIG1vcmUgc25lYWsgaW4/CgpBZnRlciBhbGwgb2YgdGhlc2UgYWN0dWFsbHkgZ2V0IGFw
cGxpZWQsCmFuZCBtYXliZSBhIGN5Y2xlIG9yIHR3byBsYXRlciwgb25lIHdvdWxkCmdldCBzZW50
LgoKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fClhlbi1k
ZXZlbCBtYWlsaW5nIGxpc3QKWGVuLWRldmVsQGxpc3RzLnhlbi5vcmcKaHR0cHM6Ly9saXN0cy54
ZW4ub3JnL3hlbi1kZXZlbAo=
