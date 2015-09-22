From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 1/9] powerpc: unexport csum_tcpudp_magic
Date: Tue, 22 Sep 2015 16:34:19 +0200 (CEST)
Message-ID: <a695a5c153c80e9343d488a3b4bb08d69d30639b.1442876807.git.christophe.leroy@c-s.fr>
References: <cover.1442876807.git.christophe.leroy@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-kernel@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 scottwood@freescale.com
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <cover.1442876807.git.christophe.leroy@c-s.fr>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

Y3N1bV90Y3B1ZHBfbWFnaWMgaXMgbm93IGFuIGlubGluZSBmdW5jdGlvbiwgc28gdGhlcmUgaXMK
bm90aGluZyB0byBleHBvcnQKClNpZ25lZC1vZmYtYnk6IENocmlzdG9waGUgTGVyb3kgPGNocmlz
dG9waGUubGVyb3lAYy1zLmZyPgotLS0KIGFyY2gvcG93ZXJwYy9saWIvcHBjX2tzeW1zLmMgfCAx
IC0KIDEgZmlsZSBjaGFuZ2VkLCAxIGRlbGV0aW9uKC0pCgpkaWZmIC0tZ2l0IGEvYXJjaC9wb3dl
cnBjL2xpYi9wcGNfa3N5bXMuYyBiL2FyY2gvcG93ZXJwYy9saWIvcHBjX2tzeW1zLmMKaW5kZXgg
YzdmOGU5NS4uZjVlNDI3ZSAxMDA2NDQKLS0tIGEvYXJjaC9wb3dlcnBjL2xpYi9wcGNfa3N5bXMu
YworKysgYi9hcmNoL3Bvd2VycGMvbGliL3BwY19rc3ltcy5jCkBAIC0yMCw3ICsyMCw2IEBAIEVY
UE9SVF9TWU1CT0woc3RybmNtcCk7CiBFWFBPUlRfU1lNQk9MKGNzdW1fcGFydGlhbCk7CiBFWFBP
UlRfU1lNQk9MKGNzdW1fcGFydGlhbF9jb3B5X2dlbmVyaWMpOwogRVhQT1JUX1NZTUJPTChpcF9m
YXN0X2NzdW0pOwotRVhQT1JUX1NZTUJPTChjc3VtX3RjcHVkcF9tYWdpYyk7CiAjZW5kaWYKIAog
RVhQT1JUX1NZTUJPTChfX2NvcHlfdG9mcm9tX3VzZXIpOwotLSAKMi4xLjAKCl9fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCkxpbnV4cHBjLWRldiBtYWlsaW5n
IGxpc3QKTGludXhwcGMtZGV2QGxpc3RzLm96bGFicy5vcmcKaHR0cHM6Ly9saXN0cy5vemxhYnMu
b3JnL2xpc3RpbmZvL2xpbnV4cHBjLWRldg==
