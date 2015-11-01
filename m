From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: ATM: MPOA: Remove 32-bit timekeeping
Date: Sun, 01 Nov 2015 16:39:09 -0500 (EST)
Message-ID: <20151101.163909.2057353716684505796.davem@davemloft.net>
References: <20151030050107.GA10611@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: y2038@lists.linaro.org, netdev@vger.kernel.org, isdn@linux-pingi.de,
 linux-kernel@vger.kernel.org, arnd@arndb.de
To: ruchandani.tina@gmail.com
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <20151030050107.GA10611@google.com>
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

RnJvbTogVGluYSBSdWNoYW5kYW5pIDxydWNoYW5kYW5pLnRpbmFAZ21haWwuY29tPgpEYXRlOiBU
aHUsIDI5IE9jdCAyMDE1IDIyOjAxOjA3IC0wNzAwCgo+IEBAIC0xNCw5ICsxNSw5IEBAIHZvaWQg
YXRtX21wb2FfaW5pdF9jYWNoZShzdHJ1Y3QgbXBvYV9jbGllbnQgKm1wYyk7Cj4gIHR5cGVkZWYg
c3RydWN0IGluX2NhY2hlX2VudHJ5IHsKPiAgCXN0cnVjdCBpbl9jYWNoZV9lbnRyeSAqbmV4dDsK
PiAgCXN0cnVjdCBpbl9jYWNoZV9lbnRyeSAqcHJldjsKPiAtCXN0cnVjdCB0aW1ldmFsICB0djsK
PiAtCXN0cnVjdCB0aW1ldmFsICByZXBseV93YWl0Owo+IC0Jc3RydWN0IHRpbWV2YWwgIGhvbGRf
ZG93bjsKPiArCXRpbWU2NF90ICB0djsKPiArCXRpbWU2NF90ICByZXBseV93YWl0Owo+ICsJdGlt
ZTY0X3QgIGhvbGRfZG93bjsKPiAgCXVpbnQzMl90ICBwYWNrZXRzX2Z3ZGVkOwo+ICAJdWludDE2
X3QgIGVudHJ5X3N0YXRlOwo+ICAJdWludDMyX3QgcmV0cnlfdGltZTsKPiBAQCAtNTEsNyArNTIs
NyBAQCBzdHJ1Y3QgaW5fY2FjaGVfb3Bzewo+ICB0eXBlZGVmIHN0cnVjdCBlZ19jYWNoZV9lbnRy
eXsKPiAgCXN0cnVjdCAgICAgICAgICAgICAgIGVnX2NhY2hlX2VudHJ5ICpuZXh0Owo+ICAJc3Ry
dWN0ICAgICAgICAgICAgICAgZWdfY2FjaGVfZW50cnkgKnByZXY7Cj4gLQlzdHJ1Y3QgICAgICAg
ICAgICAgICB0aW1ldmFsICB0djsKPiArCXRpbWU2NF90CSAgICAgdHY7CgpBZ2FpbiwgdGhlc2Ug
c3RydWN0dXJlIG1lbWJlciBuYW1lcyBsaWtlICJ0diIgb25seSBtYWtlIHNlbnNlIGlmCnRoZXkg
c3RvcmUgYSAidGltZXZhbCIuICBQbGVhc2UgcmVuYW1lIHRoZXNlIHN0cnVjdHVyZSBtZW1iZXJz
CmFwcHJvcHJpYXRlbHksIHRoYW5rcy4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX18KWTIwMzggbWFpbGluZyBsaXN0ClkyMDM4QGxpc3RzLmxpbmFyby5vcmcK
aHR0cHM6Ly9saXN0cy5saW5hcm8ub3JnL21haWxtYW4vbGlzdGluZm8veTIwMzgK
