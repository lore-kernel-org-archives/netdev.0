From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 5/5] net: Add Open vSwitch kernel
	components.
Date: Mon, 21 Nov 2011 15:18:43 -0800
Message-ID: <CAEP_g=8uoq7tJjUTAC_Sp3kOYwZJuKjD3J7Ratu67Kq56ZiyYA@mail.gmail.com>
References: <1321911029-20707-1-git-send-email-jesse@nicira.com>
	<1321911029-20707-6-git-send-email-jesse@nicira.com>
	<20111121135955.571254b1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20111121135955.571254b1-We1ePj4FEcvRI77zikRAJc56i+j3xesD0e7PPNI6Mm0@public.gmane.org>
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

T24gTW9uLCBOb3YgMjEsIDIwMTEgYXQgMTo1OSBQTSwgU3RlcGhlbiBIZW1taW5nZXIKPHNoZW1t
aW5nZXJAdnlhdHRhLmNvbT4gd3JvdGU6Cj4gT24gTW9uLCAyMSBOb3YgMjAxMSAxMzozMDoyOSAt
MDgwMAo+IEplc3NlIEdyb3NzIDxqZXNzZUBuaWNpcmEuY29tPiB3cm90ZToKPgo+PiArLyoqCj4+
ICsgKiDCoCB2cG9ydF9yZWNvcmRfZXJyb3IgLSBpbmRpY2F0ZSBkZXZpY2UgZXJyb3IgdG8gZ2Vu
ZXJpYyBzdGF0cyBsYXllcgo+PiArICoKPj4gKyAqIEB2cG9ydDogdnBvcnQgdGhhdCBlbmNvdW50
ZXJlZCB0aGUgZXJyb3IKPj4gKyAqIEBlcnJfdHlwZTogb25lIG9mIGVudW0gdnBvcnRfZXJyX3R5
cGUgdHlwZXMgdG8gaW5kaWNhdGUgdGhlIGVycm9yIHR5cGUKPj4gKyAqCj4+ICsgKiBJZiB1c2lu
ZyB0aGUgdnBvcnQgZ2VuZXJpYyBzdGF0cyBsYXllciBpbmRpY2F0ZSB0aGF0IGFuIGVycm9yIG9m
IHRoZSBnaXZlbgo+PiArICogdHlwZSBoYXMgb2NjdXJlZC4KPj4gKyAqLwo+PiArdm9pZCB2cG9y
dF9yZWNvcmRfZXJyb3Ioc3RydWN0IHZwb3J0ICp2cG9ydCwgZW51bSB2cG9ydF9lcnJfdHlwZSBl
cnJfdHlwZSkKPj4gK3sKPj4gKyDCoCDCoCBzcGluX2xvY2soJnZwb3J0LT5zdGF0c19sb2NrKTsK
Pgo+IFNvcnJ5IGZvciBvdmVyIGFuYWx5emluZyB0aGlzLi4uIGJ1dCBJIGRvbid0IHRoaW5rIHRo
ZSBzdGF0c19sb2NrCj4gaXMgbmVjZXNzYXJ5IGVpdGhlci4gVGhlIG9ubHkgdGhpbmcgaXQgaXMg
cHJvdGVjdGluZyBpcyBhZ2FpbnN0IDY0IGJpdAo+IHdyYXAuIElmIHlvdSB1c2VkIGFub3RoZXIg
dTY0X3N0YXRfc3luYyBmb3IgdGhhdCBvbmUsIGl0IGNvdWxkIGJlIGVsaW1pbmF0ZWQuCj4KPiBN
YXliZT8KClRoZSByZWFzb24gZm9yIHN0YXRzX2xvY2sgaXMgdGhhdCB0aGUgZXJyb3Igc3RhdHMg
YXJlIG5vdCBleHBlY3RlZCB0bwpiZSBjb250ZW5kZWQgc28gaW4gb3JkZXIgdG8gc2F2ZSBzb21l
IG1lbW9yeSB0aGV5J3JlIG5vdCBwZXItY3B1IGFuZAp3ZSBqdXN0IHVzZSBhIHNwaW4gbG9jayB0
byBwcm90ZWN0IHRoZW0uCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZz
d2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
