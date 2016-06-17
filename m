From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net: tilegx: use correct timespec64 type
Date: Fri, 17 Jun 2016 21:10:11 +0200
Message-ID: <20160617191011.GA10171@localhost.localdomain>
References: <20160617161540.1362545-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: y2038@lists.linaro.org, netdev@vger.kernel.org,
 Chris Metcalf <cmetcalf@mellanox.com>, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <y2038-bounces@lists.linaro.org>
Content-Disposition: inline
In-Reply-To: <20160617161540.1362545-1-arnd@arndb.de>
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

T24gRnJpLCBKdW4gMTcsIDIwMTYgYXQgMDY6MTU6MzBQTSArMDIwMCwgQXJuZCBCZXJnbWFubiB3
cm90ZToKPiBUaGUgY29udmVyc2lvbiB0byB0aGUgNjQtYml0IHRpbWUgYmFzZWQgcHRwIG1ldGhv
ZHMgbGVmdCB0d28gaW5zdGFuY2VzCj4gb2YgJ3N0cnVjdCB0aW1lc3BlYycgaW4gcGxhY2UuIFRo
aXMgaXMgaGFybWxlc3MgYmVjYXVzZSA2NC1iaXQKPiBhcmNoaXRlY3R1cmVzIGRlZmluZSB0aW1l
c3BlYzY0IGFzIHRpbWVzcGVjLCBhbmQgdGhpcyBkcml2ZXIgaXMKPiBub3QgdXNlZCBvbiAzMi1i
aXQgbWFjaGluZXMuCj4gCj4gSG93ZXZlciwgdXNpbmcgJ3N0cnVjdCB0aW1lc3BlYzY0JyBkaXJl
Y3RseSBpcyBvYnZpb3VzbHkgdGhlIHJpZ2h0Cj4gdGhpbmcgdG8gZG8sIGFuZCB3aWxsIGhlbHAg
dXMgcmVtb3ZlICdzdHJ1Y3QgdGltZXNwZWMnIGluIHRoZSBmdXR1cmUuCj4gCj4gU2lnbmVkLW9m
Zi1ieTogQXJuZCBCZXJnbWFubiA8YXJuZEBhcm5kYi5kZT4KPiBGaXhlczogYjlhY2YyNGY3Nzlj
ICgicHRwOiB0aWxlZ3g6IGNvbnZlcnQgdG8gdGhlIDY0IGJpdCBnZXQvc2V0IHRpbWUgbWV0aG9k
cy4iKQoKQWNrZWQtYnk6IFJpY2hhcmQgQ29jaHJhbiA8cmljaGFyZGNvY2hyYW5AZ21haWwuY29t
PgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpZMjAzOCBt
YWlsaW5nIGxpc3QKWTIwMzhAbGlzdHMubGluYXJvLm9yZwpodHRwczovL2xpc3RzLmxpbmFyby5v
cmcvbWFpbG1hbi9saXN0aW5mby95MjAzOAo=
