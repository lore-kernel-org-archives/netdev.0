From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/12] xen: add common function for reading
 optional value
Date: Mon, 31 Oct 2016 13:08:31 -0400 (EDT)
Message-ID: <20161031.130831.2006896157400677867.davem@davemloft.net>
References: <1477932510-28594-1-git-send-email-jgross@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-fbdev@vger.kernel.org, wei.liu2@citrix.com, linux-pci@vger.kernel.org,
 netdev@vger.kernel.org, tomi.valkeinen@ti.com, dmitry.torokhov@gmail.com,
 tpmdd@selhorst.net, linux-kernel@vger.kernel.org,
 jarkko.sakkinen@linux.intel.com, xen-devel@lists.xen.org,
 jgunthorpe@obsidianresearch.com, tpmdd-devel@lists.sourceforge.net,
 david.vrabel@citrix.com, linux-input@vger.kernel.org, bhelgaas@google.com,
 boris.ostrovsky@oracle.com, peterhuewe@gmx.de, paul.durrant@citrix.com,
 roger.pau@citrix.com
To: jgross@suse.com
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1477932510-28594-1-git-send-email-jgross@suse.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

RnJvbTogSnVlcmdlbiBHcm9zcyA8amdyb3NzQHN1c2UuY29tPgpEYXRlOiBNb24sIDMxIE9jdCAy
MDE2IDE3OjQ4OjE4ICswMTAwCgo+IFRoZXJlIGFyZSBtdWx0aXBsZSBpbnN0YW5jZXMgb2YgY29k
ZSByZWFkaW5nIGFuIG9wdGlvbmFsIHVuc2lnbmVkCj4gcGFyYW1ldGVyIGZyb20gWGVuc3RvcmUg
dmlhIHhlbmJ1c19zY2FuZigpLiBJbnN0ZWFkIG9mIHJlcGVhdGluZyB0aGUKPiBzYW1lIGNvZGUg
b3ZlciBhbmQgb3ZlciBhZGQgYSBzZXJ2aWNlIGZ1bmN0aW9uIGRvaW5nIHRoZSBqb2IgYW5kCj4g
cmVwbGFjZSB0aGUgY2FsbCBvZiB4ZW5idXNfc2NhbmYoKSB3aXRoIHRoZSBjYWxsIG9mIHRoZSBu
ZXcgZnVuY3Rpb24KPiB3aGVyZSBhcHByb3ByaWF0ZS4KCkFzIHRoaXMgc2VlbXMgdG8gYmUgYSBz
ZXJpZXMgdGhhdCB3aWxsIGdvIHRocm91Z2ggc29tZSB0cmVlIG90aGVyCnRoYW4gbWluZSwgSSBh
c3N1bWUgdGhlIG5ldHdvcmtpbmcgYml0cyB3aWxsIGJlIHRha2VuIGNhcmUgb2YgdGhhdAp3YXku
CgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpYZW4tZGV2
ZWwgbWFpbGluZyBsaXN0Clhlbi1kZXZlbEBsaXN0cy54ZW4ub3JnCmh0dHBzOi8vbGlzdHMueGVu
Lm9yZy94ZW4tZGV2ZWwK
