From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 11/12] [RFC] ipv4: avoid timespec in timestamp
	computation
Date: Wed, 30 Sep 2015 20:15:49 +0800
Message-ID: <201509302049.z9c32MsP%fengguang.wu@intel.com>
References: <1443612402-3000775-12-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Arnd Bergmann <arnd@arndb.de>, Patrick McHardy <kaber@trash.net>,
 y2038@lists.linaro.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 James Morris <jmorris@namei.org>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
 John Stultz <john.stultz@linaro.org>, kbuild-all@01.org,
 Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Thomas Gleixner <tglx@linutronix.de>,
 "David S. Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <y2038-bounces@lists.linaro.org>
Content-Disposition: inline
In-Reply-To: <1443612402-3000775-12-git-send-email-arnd@arndb.de>
List-Unsubscribe: <https://lists.linaro.org/mailman/options/y2038>,
 <mailto:y2038-request@lists.linaro.org?subject=unsubscribe>
List-Archive: <http://lists.linaro.org/pipermail/y2038/>
List-Post: <mailto:y2038@lists.linaro.org>
List-Help: <mailto:y2038-request@lists.linaro.org?subject=help>
List-Subscribe: <https://lists.linaro.org/mailman/listinfo/y2038>,
 <mailto:y2038-request@lists.linaro.org?subject=subscribe>
Errors-To: y2038-bounces@lists.linaro.org
Sender: "Y2038" <y2038-bounces@lists.linaro.org>
List-Id: netdev.vger.kernel.org

SGkgQXJuZCwKClthdXRvIGJ1aWxkIHRlc3QgcmVzdWx0cyBvbiB2NC4zLXJjMyAtLSBpZiBpdCdz
IGluYXBwcm9wcmlhdGUgYmFzZSwgcGxlYXNlIGlnbm9yZV0KCnJlcHJvZHVjZToKICAjIGFwdC1n
ZXQgaW5zdGFsbCBzcGFyc2UKICBtYWtlIEFSQ0g9eDg2XzY0IGFsbG1vZGNvbmZpZwogIG1ha2Ug
Qz0xIENGPS1EX19DSEVDS19FTkRJQU5fXwoKCnNwYXJzZSB3YXJuaW5nczogKG5ldyBvbmVzIHBy
ZWZpeGVkIGJ5ID4+KQoKPj4ga2VybmVsL3RpbWUvdGltZWtlZXBpbmcuYzo4NTA6NTogc3BhcnNl
OiBzeW1ib2wgJ2t0aW1lX2dldF9tc19vZl9kYXknIHdhcyBub3QgZGVjbGFyZWQuIFNob3VsZCBp
dCBiZSBzdGF0aWM/CgpQbGVhc2UgcmV2aWV3IGFuZCBwb3NzaWJseSBmb2xkIHRoZSBmb2xsb3d1
cCBwYXRjaC4KCi0tLQowLURBWSBrZXJuZWwgdGVzdCBpbmZyYXN0cnVjdHVyZSAgICAgICAgICAg
ICAgICBPcGVuIFNvdXJjZSBUZWNobm9sb2d5IENlbnRlcgpodHRwczovL2xpc3RzLjAxLm9yZy9w
aXBlcm1haWwva2J1aWxkLWFsbCAgICAgICAgICAgICAgICAgICBJbnRlbCBDb3Jwb3JhdGlvbgpf
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpZMjAzOCBtYWls
aW5nIGxpc3QKWTIwMzhAbGlzdHMubGluYXJvLm9yZwpodHRwczovL2xpc3RzLmxpbmFyby5vcmcv
bWFpbG1hbi9saXN0aW5mby95MjAzOAo=
