From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH v3 0/6] staging: Introduce DPAA2
 Ethernet Switch driver
Date: Sat, 14 Oct 2017 23:59:22 +0200
Message-ID: <CACRpkdbyZYP9-CoZA+BZmnaQ+5mz9fZjQ1ApVBp65XB1LmOhaw@mail.gmail.com>
References: <1507194974-12050-1-git-send-email-razvan.stefanescu@nxp.com>
 <CACRpkdYJCzu9Ph8XMYXt=SSAX+ZaiwXqUGgWX5UvTabmMxmBNQ@mail.gmail.com>
 <CACRpkdazUB_XLv2jYnSiGe9CeVTgjOQ4HfPDL8+CNUVxs-LcLA@mail.gmail.com>
 <f8b49089-f2db-f7d7-f615-1e4b5082127d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
 Andrew Lunn <andrew@lunn.ch>, ruxandra.radulescu@nxp.com,
 Arnd Bergmann <arnd@arndb.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>, alexandru.marginean@nxp.com,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Alexander Graf <agraf@suse.de>, Razvan Stefanescu <razvan.stefanescu@nxp.com>,
 Stuart Yoder <stuyoder@gmail.com>, Greg KH <gregkh@linuxfoundation.org>,
 OpenWrt Development List <openwrt-devel@lists.openwrt.org>,
 bogdan.purcareata@nxp.com, laurentiu.tudor@nxp.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <openwrt-devel-bounces@lists.openwrt.org>
In-Reply-To: <f8b49089-f2db-f7d7-f615-1e4b5082127d@gmail.com>
List-Unsubscribe: <https://lists.openwrt.org/cgi-bin/mailman/options/openwrt-devel>,
 <mailto:openwrt-devel-request@lists.openwrt.org?subject=unsubscribe>
List-Archive: <http://lists.openwrt.org/pipermail/openwrt-devel/>
List-Post: <mailto:openwrt-devel@lists.openwrt.org>
List-Help: <mailto:openwrt-devel-request@lists.openwrt.org?subject=help>
List-Subscribe: <https://lists.openwrt.org/cgi-bin/mailman/listinfo/openwrt-devel>,
 <mailto:openwrt-devel-request@lists.openwrt.org?subject=subscribe>
Errors-To: openwrt-devel-bounces@lists.openwrt.org
Sender: "openwrt-devel" <openwrt-devel-bounces@lists.openwrt.org>
List-Id: netdev.vger.kernel.org

T24gU2F0LCBPY3QgMTQsIDIwMTcgYXQgODo1MiBQTSwgRmxvcmlhbiBGYWluZWxsaSA8Zi5mYWlu
ZWxsaUBnbWFpbC5jb20+IHdyb3RlOgoKPiBUaGUgbW9zdCBkZXBsb3llZCBzd2l0Y2ggZGV2aWNl
IGRyaXZlcnMgaGF2ZSBiZWVuIGNvbnZlcnRlZCB0byBEU0EKPiBhbHJlYWR5OiBiNTMsIHFjYThr
IChhcjgzeHggaW4gT3BlbldydC9MRURFKSBhbmQgbXRrNzUzMCBhcmUgYWxsIGluCj4gdHJlZSwg
YW5kIG5vdyB3ZSBhcmUgZ2V0dGluZyBuZXcgc3VibWlzc2lvbnMgZnJvbSBNaWNocm9jaGlwIHRv
IHN1cHBvcnQKPiB0aGVpciBwcmV0dHkgbGFyZ2UgS1NaIHNlcmllcy4gQ29udmVydGluZyBmcm9t
IHN3Y29uZmlnIHRvIERTQSBpcwo+IGFjdHVhbGx5IHF1aXRlIHNpbXBsZSwgYnV0IGxpa2UgYW55
dGhpbmcgcmVxdWlyZXMgdGltZSBhbmQgdGVzdGluZywgYW5kCj4gYWNjZXNzIHRvIGhhcmR3YXJl
IGFuZCBpZGVhbGx5IGRhdGFzaGVldC4KCkhtLCBJIGhhdmUgYSBSZWFsdGVrIFJCODM2NlJCIGlu
IHRoaXMgcm91dGVyIG9uIG15IGRlc2suCgpJIGd1ZXNzIHRoYXQgbWVhbnMgSSBzaG91bGQganVz
dCB0YWtlIHRoZSBvbGQgc3dpdGNoZGV2LWJhc2VkClNNSS1kcml2ZXIgYW5kIGNvbnZlcnQgaXQg
dG8gRFNBLgoKSSBiZXQgSSBjYW4gZG8gdGhhdCA6RAoKV2VsbCwgSSB3aWxsIHRyeS4gQmVjYXVz
ZSBpdCdzIGJsb2NraW5nIG1lIHRvIHdvcmsgb24gdGhlIEdlbWluaQpldGhlcm5ldCBkcml2ZXIu
CgpZb3VycywKTGludXMgV2FsbGVpagpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fXwpvcGVud3J0LWRldmVsIG1haWxpbmcgbGlzdApvcGVud3J0LWRldmVsQGxp
c3RzLm9wZW53cnQub3JnCmh0dHBzOi8vbGlzdHMub3BlbndydC5vcmcvY2dpLWJpbi9tYWlsbWFu
L2xpc3RpbmZvL29wZW53cnQtZGV2ZWwK
