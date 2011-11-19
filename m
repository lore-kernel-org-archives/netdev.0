From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 4/4] net: Add Open vSwitch kernel
	components.
Date: Sat, 19 Nov 2011 10:19:42 -0800
Message-ID: <CAEP_g=9AS1_vB2=Cjxf=XJrbZAL6qj_qN0Ut7D_J0p3ZJHreOA@mail.gmail.com>
References: <CAEP_g=8PjK3GWuDVT36UVxWsQsGwf1WGYXZDCdax+3XqX5-T4A@mail.gmail.com>
	<93c2cdf4-43be-4a83-88a6-8f4c8a45e581@tahiti.vyatta.com>
	<20111118.203732.971277374822526847.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20111118.203732.971277374822526847.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

T24gRnJpLCBOb3YgMTgsIDIwMTEgYXQgNTozNyBQTSwgRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZl
bWxvZnQubmV0PiB3cm90ZToKPiBGcm9tOiBTdGVwaGVuIEhlbW1pbmdlciA8c3RlcGhlbi5oZW1t
aW5nZXJAdnlhdHRhLmNvbT4KPiBEYXRlOiBGcmksIDE4IE5vdiAyMDExIDE3OjA5OjE3IC0wODAw
IChQU1QpCj4KPj4KPj4+IE9uIEZyaSwgTm92IDE4LCAyMDExIGF0IDM6MjMgUE0sIFN0ZXBoZW4g
SGVtbWluZ2VyCj4+PiA8c2hlbW1pbmdlckB2eWF0dGEuY29tPiB3cm90ZToKPj4+ID4gT24gRnJp
LCAxOCBOb3YgMjAxMSAxNToxMjoxOCAtMDgwMAo+Pj4gPiBKZXNzZSBHcm9zcyA8amVzc2VAbmlj
aXJhLmNvbT4gd3JvdGU6Cj4+PiA+Cj4+PiA+PiArIMKgIMKgIMKgIMKgIMKgIMKgIHdyaXRlX3Nl
cWNvdW50X2JlZ2luKCZzdGF0cy0+c2VxbG9jayk7Cj4+PiA+PiArIMKgIMKgIMKgIMKgIMKgIMKg
IHN0YXRzLT50eF9wYWNrZXRzKys7Cj4+PiA+PiArIMKgIMKgIMKgIMKgIMKgIMKgIHN0YXRzLT50
eF9ieXRlcyArPSBzZW50Owo+Pj4gPj4gKyDCoCDCoCDCoCDCoCDCoCDCoCB3cml0ZV9zZXFjb3Vu
dF9lbmQoJnN0YXRzLT5zZXFsb2NrKTsKPj4+ID4KPj4+ID4gVGhlcmUgaXMgYSB1NjRfc3RhdHNf
c3luYyBzZXQgb2YgbWFjcm9zIGZvciB0aGlzLiBJdCBoYXMgdGhlCj4+PiA+IGFkdmFudGFnZSBv
ZiBiZWNvbWluZyBhIE5PUCBvbiA2NCBiaXQgcGxhdGZvcm1zLgo+Pj4KPj4+IFRoZSByZWFzb24g
d2h5IEkgZGlkIGl0IHRoaXMgd2F5IGlzIGl0IHRpZXMgdGhlIHBhY2tldCBhbmQgYnl0ZSBjb3Vu
dAo+Pj4gdG9nZXRoZXIuCj4+Cj4+IE9rLCBidXQgd2h5IGJvdGhlcj8KPj4gTm8gb3RoZXIgc29m
dHdhcmUgY291bnRlcnMgYm90aGVyIHRvIGdyb3VwIGJ5dGVzL3BhY2tldHMuIEV2ZW4KPj4gaGFy
ZHdhcmUgY291bnRlcnMgZ2V0IHJlYWQgc2VwYXJhdGVseS4KPgo+IEFncmVlZCwgdGhpcyBpcyB0
b3RhbGx5IHBvaW50bGVzcy4gwqBQbGVhc2UgdXNlIHRoZSB1NjQgc3RhdGUgaW50ZXJmYWNlcy4K
ClRoYXQncyBmaW5lLCBJJ2xsIGNoYW5nZSBpdC4KX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX18KZGV2IG1haWxpbmcgbGlzdApkZXZAb3BlbnZzd2l0Y2gub3Jn
Cmh0dHA6Ly9vcGVudnN3aXRjaC5vcmcvbWFpbG1hbi9saXN0aW5mby9kZXYK
