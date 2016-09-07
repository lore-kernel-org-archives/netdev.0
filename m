From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: ath9k: bring back direction setting in
	ath9k_{start_stop}
Date: Wed, 7 Sep 2016 15:23:06 +0200
Message-ID: <a331907578a94d2c8adc0de4362039e4@euamsexm01a.eu.qualcomm.com>
References: <20160901174702.8645-1-giedrius.statkevicius@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Miaoqing Pan <miaoqing@codeaurora.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, ath9k-devel@qca.qualcomm.com,
	stable@vger.kernel.org, linux-kernel@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, =?UTF-8?q?Giedrius=20Statkevi=C4=8Dius?=
	<giedrius.statkevicius@gmail.com>, kvalo@codeaurora.org
To: Giedrius Statkevi?ius <giedrius.statkevicius@gmail.com>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <20160901174702.8645-1-giedrius.statkevicius@gmail.com>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

R2llZHJpdXMgU3RhdGtldmk/aXVzIDxnaWVkcml1cy5zdGF0a2V2aWNpdXNAZ21haWwuY29tPiB3
cm90ZToKPiBBIHJlZ3Jlc3Npb24gd2FzIGludHJvZHVjZWQgaW4gY29tbWl0IGlkIDc5ZDRkYjEy
MTRhICgiYXRoOWs6IGNsZWFudXAKPiBsZWRfcGluIGluaXRpYWwiKSB0aGF0IGJyb2tlbiB0aGUg
V0xBTiBzdGF0dXMgbGVkIG9uIG15IGxhcHRvcCB3aXRoCj4gQVI5Mjg3IGFmdGVyIHN1c3BlbmRp
bmcgYW5kIHJlc3VtaW5nLgo+IAo+IFN0ZXBzIHRvIHJlcHJvZHVjZToKPiAqIFN1c3BlbmQgKGxh
cHRvcCkKPiAqIFJlc3VtZSAobGFwdG9wKQo+ICogT2JzZXJ2ZSB0aGF0IHRoZSBXTEFOIGxlZCBu
byBsb25nZXIgdHVybnMgT04vT0ZGIGRlcGVuZGluZyBvbiB0aGUKPiAgIHN0YXR1cyBhbmQgaXMg
YWx3YXlzIHJlZAo+IAo+IEV2ZW4gdGhvdWdoIGZvciBteSBjYXNlIGl0IG9ubHkgbmVlZHMgdG8g
YmUgc2V0IHRvIE9VVCBpbiBhdGg5a19zdGFydAo+IGJ1dCBmb3IgY29uc2lzdGVuY3kgYnJpbmcg
YmFjayB0aGUgSU4gZGlyZWN0aW9uIHNldHRpbmcgYXMgd2VsbC4KPiAKPiBDYzogTWlhb3Fpbmcg
UGFuIDxtaWFvcWluZ0Bjb2RlYXVyb3JhLm9yZz4KPiBDYzogS2FsbGUgVmFsbyA8a3ZhbG9AcWNh
LnF1YWxjb21tLmNvbT4KPiBDYzogPHN0YWJsZUB2Z2VyLmtlcm5lbC5vcmc+Cj4gU2lnbmVkLW9m
Zi1ieTogR2llZHJpdXMgU3RhdGtldmnEjWl1cyA8Z2llZHJpdXMuc3RhdGtldmljaXVzQGdtYWls
LmNvbT4KClRoYW5rcywgMSBwYXRjaCBhcHBsaWVkIHRvIGF0aC1jdXJyZW50IGJyYW5jaCBvZiBh
dGguZ2l0OgoKZTM0ZjJmZjQwZTAzIGF0aDlrOiBicmluZyBiYWNrIGRpcmVjdGlvbiBzZXR0aW5n
IGluIGF0aDlrX3tzdGFydF9zdG9wfQoKLS0gClNlbnQgYnkgcHdjbGkKaHR0cHM6Ly9wYXRjaHdv
cmsua2VybmVsLm9yZy9wYXRjaC85MzA5ODI5LwoKX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX18KYXRoOWstZGV2ZWwgbWFpbGluZyBsaXN0CmF0aDlrLWRldmVs
QGxpc3RzLmF0aDlrLm9yZwpodHRwczovL2xpc3RzLmF0aDlrLm9yZy9tYWlsbWFuL2xpc3RpbmZv
L2F0aDlrLWRldmVsCg==
