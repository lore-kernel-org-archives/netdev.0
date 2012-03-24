From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH linux-next] dmaengine: add context
	parameter fixups
Date: Sat, 24 Mar 2012 12:23:03 -0300
Message-ID: <CAOMZO5B-Zutv-xwqLCAgNMO8A3Kyg4uWqS41koo-yoS4mGB1TQ@mail.gmail.com>
References: <1332511242-30241-1-git-send-email-alexandre.bounine@idt.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: fabio.estevam@freescale.com, alsa-devel@alsa-project.org, samuel@sortiz.org,
	vinod.koul@intel.com, netdev@vger.kernel.org,
	broonie@opensource.wolfsonmicro.com,
	linux-kernel@vger.kernel.org, paul.gortmaker@windriver.com,
	linux-next@vger.kernel.org, tiwai@suse.de,
	dan.j.williams@intel.com, lrg@ti.com
To: Alexandre Bounine <alexandre.bounine@idt.com>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <1332511242-30241-1-git-send-email-alexandre.bounine@idt.com>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Sender: alsa-devel-bounces@alsa-project.org
Errors-To: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

T24gRnJpLCBNYXIgMjMsIDIwMTIgYXQgMTE6MDAgQU0sIEFsZXhhbmRyZSBCb3VuaW5lCjxhbGV4
YW5kcmUuYm91bmluZUBpZHQuY29tPiB3cm90ZToKPiBUaGlzIHBhdGNoIGZpeGVzIGRyaXZlcnMg
dGhhdCB1c2UgZGV2aWNlX3ByZXBfc2xhdmVfc2coKSBhbmQKPiBkZXZpY2VfcHJlcF9kbWFfY3lj
bGljKCkgaW50ZXJmYWNlcyBhbmQgaGF2ZSBiZWVuIG1pc3NlZCBkdXJpbmcgdGhlIGluaXRpYWwK
PiByZWxlYXNlIG9mIGludGVyZmFjZSBjaGFuZ2luZyBwYXRjaGVzLgo+Cj4gVGhpcyBwYXRjaCBp
cyBiYXNlZCBvbiBsaW51eC1uZXh0LTIwMTIwMzIyIGNvZGUgdHJlZS4KPiBTZWUgaHR0cHM6Ly9s
a21sLm9yZy9sa21sLzIwMTIvMy8yMi8zMzkgZm9yIGJ1aWxkIGZhaWx1cmUgcmVwb3J0Lgo+Cj4g
U2lnbmVkLW9mZi1ieTogQWxleGFuZHJlIEJvdW5pbmUgPGFsZXhhbmRyZS5ib3VuaW5lQGlkdC5j
b20+Cj4gUmVwb3J0ZWQtYnk6IFBhdWwgR29ydG1ha2VyIDxwYXVsLmdvcnRtYWtlckB3aW5kcml2
ZXIuY29tPgo+IC0tLQo+IMKgZHJpdmVycy9kbWEvc2ExMXgwLWRtYS5jIMKgIMKgIMKgfCDCoCDC
oDIgKy0KPiDCoGRyaXZlcnMvbmV0L2lyZGEvc2ExMTAwX2lyLmMgwqB8IMKgIMKgMiArLQo+IMKg
c291bmQvc29jL3NoL2ZzaS5jIMKgIMKgIMKgIMKgIMKgIMKgfCDCoCDCoDcgKysrLS0tLQo+IMKg
c291bmQvc29jL3NvYy1kbWFlbmdpbmUtcGNtLmMgfCDCoCDCoDIgKy0KCkkgaGF2ZSBhbHJlYWR5
IHRha2VuIGNhcmUgb2Ygc291bmQvc29jL3NvYy1kbWFlbmdpbmUtcGNtLmM6Cmh0dHA6Ly9wZXJt
YWxpbmsuZ21hbmUub3JnL2dtYW5lLmxpbnV4LmFsc2EuZGV2ZWwvOTYyMTUKX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KQWxzYS1kZXZlbCBtYWlsaW5nIGxp
c3QKQWxzYS1kZXZlbEBhbHNhLXByb2plY3Qub3JnCmh0dHA6Ly9tYWlsbWFuLmFsc2EtcHJvamVj
dC5vcmcvbWFpbG1hbi9saXN0aW5mby9hbHNhLWRldmVsCg==
