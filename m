From: Rafal Milecki <rafal@milecki.pl>
Subject: Re: [PATCH v6 6/7] net: ethernet: bgmac: add NS2 support
Date: Fri, 4 Nov 2016 07:48:17 +0100
Message-ID: <6fafd841-6ab0-c402-d5d4-a9b719966033@milecki.pl>
References: <1478236262-3351-1-git-send-email-jon.mason@broadcom.com>
 <1478236262-3351-7-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 devicetree@vger.kernel.org
To: Jon Mason <jon.mason@broadcom.com>, David Miller <davem@davemloft.net>,
 Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
 Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1478236262-3351-7-git-send-email-jon.mason@broadcom.com>
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

T24gMTEvMDQvMjAxNiAwNjoxMSBBTSwgSm9uIE1hc29uIHdyb3RlOgo+IEFkZCBzdXBwb3J0IGZv
ciB0aGUgdmFyaWFudCBvZiBhbWFjIGhhcmR3YXJlIHByZXNlbnQgaW4gdGhlIEJyb2FkY29tCj4g
Tm9ydGhzdGFyMiBiYXNlZCBTb0NzLiAgTm9ydGhzdGFyMiByZXF1aXJlcyBhbiBhZGRpdGlvbmFs
IHJlZ2lzdGVyIHRvIGJlCj4gY29uZmlndXJlZCB3aXRoIHRoZSBwb3J0IHNwZWVkL2R1cGxleGl0
eSAoTklDUE0pLiAgVGhpcyBjYW4gYmUgYWRkZWQgdG8KPiB0aGUgbGluayBjYWxsYmFjayB0byBo
aWRlIGl0IGZyb20gdGhlIGluc3RhbmNlcyB0aGF0IGRvIG5vdCB1c2UgdGhpcy4KPiBBbHNvLCBj
bGVhcmluZyBvZiB0aGUgcGVuZGluZyBpbnRlcnJ1cHRzIG9uIGluaXQgaXMgcmVxdWlyZWQgZHVl
IHRvCj4gb2JzZXJ2ZWQgaXNzdWVzIG9uIHNvbWUgcGxhdGZvcm1zLgo+Cj4gU2lnbmVkLW9mZi1i
eTogSm9uIE1hc29uIDxqb24ubWFzb25AYnJvYWRjb20uY29tPgo+IFJldmlld2VkLWJ5OiBGbG9y
aWFuIEZhaW5lbGxpIDxmLmZhaW5lbGxpQGdtYWlsLmNvbT4KCkNoZWNrZWQgZm9yIHBvc3NpYmxl
IHJlZ3Jlc3Npb25zIG9uIE5vcnRoc3RhciwgbG9va3MgT0suCgpBY2tlZC1ieTogUmFmYcWCIE1p
xYJlY2tpIDxyYWZhbEBtaWxlY2tpLnBsPgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX18KbGludXgtYXJtLWtlcm5lbCBtYWlsaW5nIGxpc3QKbGludXgtYXJt
LWtlcm5lbEBsaXN0cy5pbmZyYWRlYWQub3JnCmh0dHA6Ly9saXN0cy5pbmZyYWRlYWQub3JnL21h
aWxtYW4vbGlzdGluZm8vbGludXgtYXJtLWtlcm5lbAo=
