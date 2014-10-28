From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCHv2 1/6] net: fec: indentation cleanup; no functional change
Date: Tue, 28 Oct 2014 12:01:39 +0100
Message-ID: <1414494104-27943-2-git-send-email-LW@KARO-electronics.de>
References: <1414494104-27943-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Fabio Estevam <fabio.estevam@freescale.com>,
 Frank Li <Frank.Li@freescale.com>, linux-kernel@vger.kernel.org,
 Russell King <rmk+kernel@arm.linux.org.uk>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
 =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1414494104-27943-1-git-send-email-LW@KARO-electronics.de>
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

ClNpZ25lZC1vZmYtYnk6IExvdGhhciBXYcOfbWFubiA8TFdAS0FSTy1lbGVjdHJvbmljcy5kZT4K
LS0tCiBkcml2ZXJzL25ldC9ldGhlcm5ldC9mcmVlc2NhbGUvZmVjX21haW4uYyB8ICAgIDIgKy0K
IDEgZmlsZSBjaGFuZ2VkLCAxIGluc2VydGlvbigrKSwgMSBkZWxldGlvbigtKQoKZGlmZiAtLWdp
dCBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ZyZWVzY2FsZS9mZWNfbWFpbi5jIGIvZHJpdmVycy9u
ZXQvZXRoZXJuZXQvZnJlZXNjYWxlL2ZlY19tYWluLmMKaW5kZXggZTM2NGQxZi4uZGVjZWE1NyAx
MDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJlZXNjYWxlL2ZlY19tYWluLmMKKysr
IGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJlZXNjYWxlL2ZlY19tYWluLmMKQEAgLTEwMSw3ICsx
MDEsNyBAQCBzdGF0aWMgdm9pZCBmZWNfZW5ldF9pdHJfY29hbF9pbml0KHN0cnVjdCBuZXRfZGV2
aWNlICpuZGV2KTsKICAqIGZyYW1lcyBub3QgYmVpbmcgdHJhbnNtaXR0ZWQgdW50aWwgdGhlcmUg
aXMgYSAwLXRvLTEgdHJhbnNpdGlvbiBvbgogICogRU5FVF9UREFSW1REQVJdLgogICovCi0jZGVm
aW5lIEZFQ19RVUlSS19FUlIwMDYzNTggICAgICAgICAgICAoMSA8PCA3KQorI2RlZmluZSBGRUNf
UVVJUktfRVJSMDA2MzU4CQkoMSA8PCA3KQogLyogRU5FVCBJUCBodyBBVkIKICAqCiAgKiBpLk1Y
NlNYIEVORVQgSVAgYWRkIEF1ZGlvIFZpZGVvIEJyaWRnaW5nIChBVkIpIGZlYXR1cmUgc3VwcG9y
dC4KLS0gCjEuNy4xMC40CgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX18KbGludXgtYXJtLWtlcm5lbCBtYWlsaW5nIGxpc3QKbGludXgtYXJtLWtlcm5lbEBs
aXN0cy5pbmZyYWRlYWQub3JnCmh0dHA6Ly9saXN0cy5pbmZyYWRlYWQub3JnL21haWxtYW4vbGlz
dGluZm8vbGludXgtYXJtLWtlcm5lbAo=
