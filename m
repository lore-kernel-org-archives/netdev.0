From: Caesar Wang <wxt@rock-chips.com>
Subject: Re: [PATCH v3 3/5] arm64: dts: rockchip: add the gmac power domain
 on rk3399
Date: Fri, 02 Sep 2016 01:53:37 +0800
Message-ID: <57C86B21.4090409@rock-chips.com>
References: <1472686132-27827-1-git-send-email-wxt@rock-chips.com>
 <1472686132-27827-4-git-send-email-wxt@rock-chips.com>
 <2409903.3qiu7FpA8p@diego>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: Mark Rutland <mark.rutland@arm.com>, Huang Tao <huangtao@rock-chips.com>,
 dbasehore@chromium.org, Elaine Zhang <zhangqing@rock-chips.com>,
 Xing Zheng <zhengxing@rock-chips.com>, linux-rockchip@lists.infradead.org,
 netdev@vger.kernel.org, Jianqun Xu <jay.xu@rock-chips.com>,
 Brian Norris <briannorris@chromium.org>, Will Deacon <will.deacon@arm.com>,
 Douglas Anderson <dianders@chromium.org>, linux-kernel@vger.kernel.org,
 Masahiro Yamada <yamada.masahiro@socionext.com>, devicetree@vger.kernel.org,
 Rob Herring <robh+dt@kernel.org>, Roger Chen <roger.chen@rock-chips.com>,
 Catalin Marinas <catalin.marinas@arm.com>, David Wu <david.wu@rock-chips.com>,
 Shunqian Zheng <zhengsq@rock-chips.com>, linux-arm-kernel@lists.infradead.org,
 Caesar Wang <wxt@rock-chips.com>
To: =?UTF-8?B?SGVpa28gU3TDvGJuZXI=?= <heiko@sntech.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <2409903.3qiu7FpA8p@diego>
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

Ck9uIDIwMTblubQwOeaciDAx5pelIDE5OjQxLCBIZWlrbyBTdMO8Ym5lciB3cm90ZToKPiBIaSBD
YWVzYXIsCj4KPiBBbSBEb25uZXJzdGFnLCAxLiBTZXB0ZW1iZXIgMjAxNiwgMDc6Mjg6NTAgc2No
cmllYiBDYWVzYXIgV2FuZzoKPj4gVGhpcyBwYXRjaCBzdXBwb3J0cyB0aGUgZ21hYyBwZCB0byBz
YXZlIHBvd2VyIGNvbnN1bXB0aW9uLgo+PiBFdmVuIHRob3VnaCBzb21lIGJvYXJkcyBub3QgbmVl
ZCBFdGhlcm5ldCBzdXBwb3J0LCB0aGUgZHJpdmVyCj4+IGNvcmUgY2FuIGFsc28gdGFrZSBjYXJl
IG9mIHBvd2VyaW5nIHVwIHRoZSBwZCBiZWZvcmUgcHJvYmUuCj4+Cj4+IFNpZ25lZC1vZmYtYnk6
IFJvZ2VyIENoZW4gPHJvZ2VyLmNoZW5Acm9jay1jaGlwcy5jb20+Cj4+IFNpZ25lZC1vZmYtYnk6
IENhZXNhciBXYW5nIDx3eHRAcm9jay1jaGlwcy5jb20+Cj4gd2hvIGlzIHRoZSBhdXRob3Igb2Yg
dGhpcyBwYXRjaD8gUm9nZXIgb3IgeW91PyBCZWNhdXNlIHdlIHNob3VsZCBlaXRoZXIgZHJvcAo+
IFJvZ2VyJ3MgU2lnbmVkLW9mZiBvciBmaXggdGhlIGF1dGhvcnNoaXAgdG8gbGlzdCBoaW0uCgpU
aGFua3MgZm9yIHJlbWluZGluZyBtZS4KQ2FuIHlvdSB0YWtlIGEgbG9vayBhdCB0aGUgbmV3ZXIg
djQgc2VyaWVzIHBhdGNoZXM/IDopCmh0dHBzOi8vcGF0Y2h3b3JrLmtlcm5lbC5vcmcvcGF0Y2gv
OTMwODAxMy8KCgo+Cj4KPiBIZWlrbwo+Cj4+IC0tLQo+Pgo+PiBDaGFuZ2VzIGluIHYzOgo+PiAt
IGxlYXZlIGludG8gdHdvIHBhdGNoZXMgYmFzZWQgb24gcGF0Y2h2MiwgYW5kIGZpeCBuaXRzIGFu
ZCBjb21taXQsIGFzCj4+ICAgIGNvbW1lbnQgb24gaHR0cHM6Ly9wYXRjaHdvcmsua2VybmVsLm9y
Zy9wYXRjaC85MzA2MzM5Lwo+Pgo+PiBDaGFuZ2VzIGluIHYyOgo+PiAtIEZpeGVzIHRoZSBvcmRl
ciwgc3MgSGVpa28gY29tbW5ldHMgb24KPj4gICAgaHR0cHM6Ly9wYXRjaHdvcmsua2VybmVsLm9y
Zy9wYXRjaC85MzA1OTkxLwo+Pgo+PiAgIGFyY2gvYXJtNjQvYm9vdC9kdHMvcm9ja2NoaXAvcmsz
Mzk5LmR0c2kgfCAxMCArKysrKysrKysrCj4+ICAgMSBmaWxlIGNoYW5nZWQsIDEwIGluc2VydGlv
bnMoKykKPj4KPj4gZGlmZiAtLWdpdCBhL2FyY2gvYXJtNjQvYm9vdC9kdHMvcm9ja2NoaXAvcmsz
Mzk5LmR0c2kKPj4gYi9hcmNoL2FybTY0L2Jvb3QvZHRzL3JvY2tjaGlwL3JrMzM5OS5kdHNpIGlu
ZGV4IDMyYWViYzguLjJhYjIzM2YgMTAwNjQ0Cj4+IC0tLSBhL2FyY2gvYXJtNjQvYm9vdC9kdHMv
cm9ja2NoaXAvcmszMzk5LmR0c2kKPj4gKysrIGIvYXJjaC9hcm02NC9ib290L2R0cy9yb2NrY2hp
cC9yazMzOTkuZHRzaQo+PiBAQCAtNjExLDYgKzYxMSwxMSBAQAo+PiAgIAkJc3RhdHVzID0gImRp
c2FibGVkIjsKPj4gICAJfTsKPj4KPj4gKwlxb3NfZ21hYzogcW9zQGZmYTVjMDAwIHsKPj4gKwkJ
Y29tcGF0aWJsZSA9ICJzeXNjb24iOwo+PiArCQlyZWcgPSA8MHgwIDB4ZmZhNWMwMDAgMHgwIDB4
MjA+Owo+PiArCX07Cj4+ICsKPj4gICAJcW9zX2hkY3A6IHFvc0BmZmE5MDAwMCB7Cj4+ICAgCQlj
b21wYXRpYmxlID0gInN5c2NvbiI7Cj4+ICAgCQlyZWcgPSA8MHgwIDB4ZmZhOTAwMDAgMHgwIDB4
MjA+Owo+PiBAQCAtNzM5LDYgKzc0NCwxMSBAQAo+PiAgIAkJCX07Cj4+Cj4+ICAgCQkJLyogVGhl
c2UgcG93ZXIgZG9tYWlucyBhcmUgZ3JvdXBlZCBieSBWRF9MT0dJQyAqLwo+PiArCQkJcGRfZ21h
Y0BSSzMzOTlfUERfR01BQyB7Cj4+ICsJCQkJcmVnID0gPFJLMzM5OV9QRF9HTUFDPjsKPj4gKwkJ
CQljbG9ja3MgPSA8JmNydSBBQ0xLX0dNQUM+Owo+PiArCQkJCXBtX3FvcyA9IDwmcW9zX2dtYWM+
Owo+PiArCQkJfTsKPj4gICAJCQlwZF92aW9AUkszMzk5X1BEX1ZJTyB7Cj4+ICAgCQkJCXJlZyA9
IDxSSzMzOTlfUERfVklPPjsKPj4gICAJCQkJI2FkZHJlc3MtY2VsbHMgPSA8MT47Cj4KPiBfX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwo+IExpbnV4LXJvY2tj
aGlwIG1haWxpbmcgbGlzdAo+IExpbnV4LXJvY2tjaGlwQGxpc3RzLmluZnJhZGVhZC5vcmcKPiBo
dHRwOi8vbGlzdHMuaW5mcmFkZWFkLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2xpbnV4LXJvY2tjaGlw
CgoKLS0gCmNhZXNhciB3YW5nIHwgc29mdHdhcmUgZW5naW5lZXIgfCB3eHRAcm9jay1jaGlwLmNv
bQoKCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpsaW51
eC1hcm0ta2VybmVsIG1haWxpbmcgbGlzdApsaW51eC1hcm0ta2VybmVsQGxpc3RzLmluZnJhZGVh
ZC5vcmcKaHR0cDovL2xpc3RzLmluZnJhZGVhZC5vcmcvbWFpbG1hbi9saXN0aW5mby9saW51eC1h
cm0ta2VybmVsCg==
