From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next 0/2] Pack struct
 xfrm_usersa_info and struct xfrm_userpolicy_info
Date: Tue, 7 Jan 2014 15:59:56 +0800
Message-ID: <52CBB3FC.9050207@windriver.com>
References: <1389077339-12814-1-git-send-email-fan.du@windriver.com>
	<20140107074724.GV31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: stephen@networkplumber.org, netdev@vger.kernel.org, davem@davemloft.net,
	dev@lists.strongswan.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <dev-bounces+gnvsd-dev=m.gmane.org@lists.strongswan.org>
In-Reply-To: <20140107074724.GV31491@secunet.com>
List-Unsubscribe: <https://lists.strongswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.strongswan.org?subject=unsubscribe>
List-Archive: <http://lists.strongswan.org/pipermail/dev>
List-Post: <mailto:dev@lists.strongswan.org>
List-Help: <mailto:dev-request@lists.strongswan.org?subject=help>
List-Subscribe: <https://lists.strongswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.strongswan.org?subject=subscribe>
Sender: dev-bounces+gnvsd-dev=m.gmane.org@lists.strongswan.org
Errors-To: dev-bounces+gnvsd-dev=m.gmane.org@lists.strongswan.org
List-Id: netdev.vger.kernel.org

CgpPbiAyMDE05bm0MDHmnIgwN+aXpSAxNTo0NywgU3RlZmZlbiBLbGFzc2VydCB3cm90ZToKPiBP
biBUdWUsIEphbiAwNywgMjAxNCBhdCAwMjo0ODo1N1BNICswODAwLCBGYW4gRHUgd3JvdGU6Cj4+
IFdoZW4gdHJ5aW5nIHRvIHNldHVwIElQc2VjIGNvbmZpZ3VyYXRpb24gb24gYSA2NGJpdHMgaG9z
dCB3aXRoCj4+IGlwcm91dGUyKDMyYml0cyBjb21waWxlZCksIHRoZSBpbnRlbmVkIHhmcm0gcG9s
aWN5IGFuZCBzYSBpcwo+PiBlaXRoZXIgZGVmaWNpdCBvciB3cm9uZyB3aGVuIGtlcm5lbCB0cnlp
bmcgdG8gcGFyc2UgdXNlciBsYW5kCj4+IGluZm9ybWF0aW9uLgo+Pgo+PiBGdXJ0aGVyIGludmVz
dGlnYXRpbm8gc2hvd3MgdGhhdDoKPj4gTDoga2VybmVsCj4+IFI6IGlwcm91dGUyCj4+Cj4+ICAg
ICAgICAgICAgc2l6ZW9mICAgICAgIHVzZXJwb2xpY3kgICAgICB1c2Vyc2EKPj4gNjRiaXRzKHVu
cGFja2VkKSAgICAgICAgMTY4LzE2OCAgICAgICAgMjI0LzIyNAo+PiAzMmJpdHModW5wYWNrZWQp
ICAgICAgICAxNjQvMTY0ICAgICAgICAyMjAvMjIwCj4+ICAgICAgICAgICAgICAgICAgICAgICAg
ICAgXiAgIF4KPj4gICAgICAgICAgICAgICAgICAgICAgICAgICBMICAgUgo+Pgo+PiBUbyBrZWVw
IGtlcm5lbCBhbmQgdXNlciBsYW5kIHNlZSBhIGNvbnNpc3RlbnQgc3RydWN0dXJlLCBhZnRlcgo+
PiBhZGQgcGFja2luZyBhdHRyaWJ1dGUsIG5vdyBpdCBsb29rcyBsaWtlIHRoaXM6Cj4+Cj4+IDY0
Yml0cyggIHBhY2tlZCkgICAgICAgIDE2NC8xNjQgICAgICAgIDIxNy8yMTcKPj4gMzJiaXRzKCAg
cGFja2VkKSAgICAgICAgMTY0LzE2NCAgICAgICAgMjE3LzIxNwo+PiAgICAgICAgICAgICAgICAg
ICAgICAgICAgIF4gICBeCj4+ICAgICAgICAgICAgICAgICAgICAgICAgICAgTCAgIFIKPj4KPgo+
IFdlIGRvbid0IGNoYW5nZSB1c2Vyc3BhY2UgZXhwb3J0ZWQgc3RydWN0dXJlcy4gVGhpcyBicmVh
a3MKPiBleGlzdGluZyB1c2Vyc3BhY2UgdG9vbHMuCj4KClRoZW4gdXNlciB3aXRoIDMyYml0cyBp
cHJvdXRlMiBvciBTdHJvbmdTd2FuIGhhcyB0byByZWJ1aWxkIGFzIDY0Yml0cz8KCi0tIArmta7m
sonpmo/mtarlj6rorrDku4rmnJ3nrJEKCi0tZmFuCgpfX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fXwpEZXYgbWFpbGluZyBsaXN0CkRldkBsaXN0cy5zdHJvbmdz
d2FuLm9yZwpodHRwczovL2xpc3RzLnN0cm9uZ3N3YW4ub3JnL21haWxtYW4vbGlzdGluZm8vZGV2
