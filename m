From: Sebastian Huber <sebastian.huber@embedded-brains.de>
Subject: Re: [PATCH] soc/qbman: Simplify bman_release()
Date: Fri, 20 Oct 2017 11:35:18 +0200
Message-ID: <f25ecaec-1a78-7b72-1ed0-45d0a818e9bb@embedded-brains.de>
References: <20170710072859.2616-1-sebastian.huber@embedded-brains.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org,
 Madalin Bucur <madalin.bucur@nxp.com>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170710072859.2616-1-sebastian.huber@embedded-brains.de>
Content-Language: en-GB
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

UGluZy4KCk9uIDEwLzA3LzE3IDA5OjI4LCBTZWJhc3RpYW4gSHViZXIgd3JvdGU6Cj4gR2V0IHRo
ZSBhZmZpbmUgcG9ydGFsIG9ubHkgb25jZSBmb3IgdGhlIGNvbXBsZXRlIHRyYW5zYWN0aW9uLgo+
Cj4gU2lnbmVkLW9mZi1ieTogU2ViYXN0aWFuIEh1YmVyIDxzZWJhc3RpYW4uaHViZXJAZW1iZWRk
ZWQtYnJhaW5zLmRlPgoKLS0gClNlYmFzdGlhbiBIdWJlciwgZW1iZWRkZWQgYnJhaW5zIEdtYkgK
CkFkZHJlc3MgOiBEb3JuaWVyc3RyLiA0LCBELTgyMTc4IFB1Y2hoZWltLCBHZXJtYW55ClBob25l
ICAgOiArNDkgODkgMTg5IDQ3IDQxLTE2CkZheCAgICAgOiArNDkgODkgMTg5IDQ3IDQxLTA5CkUt
TWFpbCAgOiBzZWJhc3RpYW4uaHViZXJAZW1iZWRkZWQtYnJhaW5zLmRlClBHUCAgICAgOiBQdWJs
aWMga2V5IGF2YWlsYWJsZSBvbiByZXF1ZXN0LgoKRGllc2UgTmFjaHJpY2h0IGlzdCBrZWluZSBn
ZXNjaMOkZnRsaWNoZSBNaXR0ZWlsdW5nIGltIFNpbm5lIGRlcyBFSFVHLgoKCl9fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmxpbnV4LWFybS1rZXJuZWwgbWFp
bGluZyBsaXN0CmxpbnV4LWFybS1rZXJuZWxAbGlzdHMuaW5mcmFkZWFkLm9yZwpodHRwOi8vbGlz
dHMuaW5mcmFkZWFkLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2xpbnV4LWFybS1rZXJuZWwK
