From: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH 2/4] ARM: kirkwood: add device node entries for the gigabit
 interfaces
Date: Wed, 03 Apr 2013 11:27:02 +0200
Message-ID: <515BF5E6.5040703@openwrt.org>
References: <1364580879-4297-1-git-send-email-florian@openwrt.org>
 <1364580879-4297-3-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: moinejf-GANU6spQydw@public.gmane.org, jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org, buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1364580879-4297-3-git-send-email-florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

TGUgMDMvMjkvMTMgMTk6MTQsIEZsb3JpYW4gRmFpbmVsbGkgYSDDqWNyaXQgOgo+IFRoaXMgcGF0
Y2ggbW9kaWZpZXMga2lya3dvb2QuZHRzaSB0byBzcGVjaWZ5IHRoZSB2YXJpb3VzIGdpZ2FiaXQK
PiBpbnRlcmZhY2VzIG5vZGVzIGF2YWlsYWJsZSBvbiBraXJrd29vZCBkZXZpY2VzLiBUaGV5IGFy
ZSBkaXNhYmxlZCBieQo+IGRlZmF1bHQgYW5kIHNob3VsZCBiZSBlbmFibGVkIG9uIGEgcGVyLWJv
YXJkIGJhc2lzLiBlZ2lnYTAgYW5kIGVnaWdhMQo+IGFsaWFzZXMgYXJlIGRlZmluZWQgZm9yIGNv
bnZlbmllbmNlLiBUaGUgbWRpbyBub2RlIGlzIGFsc28gcHJlc2VudCBhbmQKPiBzaG91bGQgYmUg
ZW5hYmxlZCBvbiBhIHBlci1ib2FyZCBiYXNpcyBhcyB3ZWxsLgo+Cj4gU2lnbmVkLW9mZi1ieTog
RmxvcmlhbiBGYWluZWxsaSA8ZmxvcmlhbkBvcGVud3J0Lm9yZz4KPiAtLS0KCltzbmlwXQoKPiAr
Cj4gKwkJZXRoZXJuZXQtZ3JvdXBANzAwMDAgewoKVGhpcyBvbmUgaXMgb2ZmLWJ5IDB4MjAwMCBh
bmQgc2hvdWxkIGhhdmUgYmVlbiA3MjAwMAoKPiArCQkJI2FkZHJlc3MtY2VsbHMgPSA8MT47Cj4g
KwkJCSNzaXplLWNlbGxzID0gPDA+Owo+ICsJCQljb21wYXRpYmxlID0gIm1hcnZlbGwsbXY2NDN4
eC1ldGgtYmxvY2siOwo+ICsJCQlyZWcgPSA8MHg3MDAwMCAweDQwMDA+OwoKU2FtZSBoZXJlCgo+
ICsJCQl0eC1jc3VtLWxpbWl0ID0gPDE2MDA+Owo+ICsJCQlzdGF0dXMgPSAiZGlzYWJsZWQiOwo+
ICsKPiArCQkJZWdpZ2EwOiBlZ2lnYTBAMCB7Cj4gKwkJCQlkZXZpY2VfdHlwZSA9ICJuZXR3b3Jr
IjsKPiArCQkJCWNvbXBhdGlibGUgPSAibWFydmVsbCxtdjY0M3h4LWV0aCI7Cj4gKwkJCQlyZWcg
PSA8MD47Cj4gKwkJCQlpbnRlcnJ1cHRzID0gPDExPjsKPiArCQkJCWNsb2NrcyA9IDwmZ2F0ZV9j
bGsgMD47Cj4gKwkJCQljbG9jay1uYW1lcyA9ICIwIjsKPiArCQkJfTsKPiArCQl9Owo+ICsKPiAr
CQlldGhlcm5ldC1ncm91cEA3NDAwMCB7CgpBbmQgaGVyZSwgaXQgc2hvdWxkIGJlIDc2MDAwCgo+
ICsJCQkjYWRkcmVzcy1jZWxscyA9IDwxPjsKPiArCQkJI3NpemUtY2VsbHMgPSA8MD47Cj4gKwkJ
CWNvbXBhdGlibGUgPSAibWFydmVsbCxtdjY0M3h4LWV0aC1ibG9jayI7Cj4gKwkJCXJlZyA9IDww
eDc0MDAwIDB4NDAwMD47CgpBbmQgaGVyZSB0b28uCi0tCkZsb3JpYW4KX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KZGV2aWNldHJlZS1kaXNjdXNzIG1haWxp
bmcgbGlzdApkZXZpY2V0cmVlLWRpc2N1c3NAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xpc3Rz
Lm96bGFicy5vcmcvbGlzdGluZm8vZGV2aWNldHJlZS1kaXNjdXNzCg==
