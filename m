From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: on kernel 2.6.34.15, vlan and raw packets can not be received
 with gfar-enet nic
Date: Thu, 03 Apr 2014 18:18:04 +0800
Message-ID: <533D355C.6050501@gmail.com>
References: <53310F4E.4080104@gmail.com> <533D25D4.4000607@gmail.com>
 <20140403092727.GD16158@1wt.eu> <533D30A1.1060509@gmail.com>
 <20140403100128.GE16158@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: "Yang, Zhangle \(Eric\)" <Zhangle.Yang@windriver.com>,
 netdev@vger.kernel.org, richardcochran@gmail.com,
 linuxppc-dev@lists.ozlabs.org, guang.yang@windriver.com,
 linux-kernel@vger.kernel.org, yongjun_wei@trendmicro.com.cn,
 zhuyj <zyjzyj2000@gmail.com>, sandeep.kumar@freescale.com,
 Claudiu Manoil <claudiu.manoil@freescale.com>, "Tao,
 Yue" <Yue.Tao@windriver.com>, joe@perches.com, festevam@gmail.com,
 clarocq@gmail.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20140403100128.GE16158@1wt.eu>
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

T24gMDQvMDMvMjAxNCAwNjowMSBQTSwgV2lsbHkgVGFycmVhdSB3cm90ZToKPiBIaSBaaHUsCj4K
PiBPbiBUaHUsIEFwciAwMywgMjAxNCBhdCAwNTo1Nzo1M1BNICswODAwLCB6aHV5aiB3cm90ZToK
Pj4gSSByZWZlcmVuY2UgdGhlIGZvbGxvd2luZyAyIG1haW5saW5lIGNvbW1pdHMuIFRoZXNlIDIg
Y29tbWl0cyBhcmUgYmFzZWQKPj4gb24gdGhlIGN1cnJlbnQga2VybmVsIDMueCBhbmQgZXRodG9v
bC4KPj4gSWYgd2Ugb25seSBiYWNrcG9ydCB0aGVzZSAyIGNvbW1pdHMgb24ga2VybmVsIDIuNi54
LCB0aGlzIHByb2JsZW0gd2lsbAo+PiBub3QgYmUgZml4ZWQgeWV0Lgo+IE9LIGZpbmUsIEkganVz
dCB3YW50ZWQgdGhhdCB3ZSBrZWVwIHRoZSByZWZlcmVuY2Ugb2YgdGhlc2UgZXF1aXZhbGVudAo+
IHBhdGNoZXMgaW4gdGhlIGNvbW1pdCBtZXNzYWdlIHNvIHRoYXQgaWYgbGF0ZXIgYSBuZXdlciBw
YXRjaCBjaGFuZ2VzCj4gYW55dGhpbmcgdGhleSBkaWQsIGF0IGxlYXN0IHdlIGhhdmUgc29tZSBp
bmRpY2F0aW9ucyB0aGF0IHRoZSBjb21taXQKPiBtaWdodCBhbHNvIGhhdmUgdG8gYmUgcmV2aXNp
dGVkLgo+Cj4gSSdsbCBtZXJnZSB5b3VyIHBhdGNoIGFuZCBwdXQgdGhlc2UgcmVmZXJlbmNlcyB0
aGVyZS4KPgo+IFRoYW5rcywKPiBXaWxseQpPSy4gVGhhbmtzIGEgbG90LgoKWmh1IFlhbmp1bgo+
IC4KPgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGlu
dXhwcGMtZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRw
czovL2xpc3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2
