From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] Revert "vhost: cache used event for better
	performance"
Date: Wed, 26 Jul 2017 19:56:09 +0800
Message-ID: <f52acfca-adf1-fffc-946c-675ce9e033ae@redhat.com>
References: <1501056197-3368-1-git-send-email-jasowang@redhat.com>
	<da300d74-ca7a-a636-0ed6-6aa78e6a5510@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Christian Borntraeger <borntraeger@de.ibm.com>, mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <da300d74-ca7a-a636-0ed6-6aa78e6a5510@de.ibm.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

CgpPbiAyMDE35bm0MDfmnIgyNuaXpSAxODo1MywgQ2hyaXN0aWFuIEJvcm50cmFlZ2VyIHdyb3Rl
Ogo+IE9uIDA3LzI2LzIwMTcgMTA6MDMgQU0sIEphc29uIFdhbmcgd3JvdGU6Cj4+IFRoaXMgcmV2
ZXJ0cyBjb21taXQgODA5ZWNiOWJjYTZhOTQyNGNjZDM5MmQ2N2UzNjgxNjBmOGI3NmM5Mi4gU2lu
Y2UgaXQKPj4gd2FzIHJlcG9ydGVkIHRvIGJyZWFrIHZob3N0X25ldC4gV2Ugd2FudCB0byBjYWNo
ZSB1c2VkIGV2ZW50IGFuZCB1c2UKPj4gaXQgdG8gY2hlY2sgZm9yIG5vdGlmaWNhdGlvbi4gV2Ug
dHJ5IHRvIHZhbGlkIGNhY2hlZCB1c2VkIGV2ZW50IGJ5Cj4+IGNoZWNraW5nIHdoZXRoZXIgb3Ig
bm90IGl0IHdhcyBhaGVhZCBvZiBuZXcsIGJ1dCB0aGlzIGlzIG5vdCBjb3JyZWN0Cj4+IGFsbCB0
aGUgdGltZSwgaXQgY291bGQgYmUgc3RhbGUgYW5kIHRoZXJlJ3Mgbm8gd2F5IHRvIGtub3cgYWJv
dXQgdGhpcy4KPj4KPj4gU2lnbmVkLW9mZi1ieTogSmFzb24gV2FuZyA8amFzb3dhbmdAcmVkaGF0
LmNvbT4KPiBUaGlzIHdvdWxkIHRoZW4gcXVhbGlmeSBmb3Igc3RhYmxlID8KPgoKWWVzIGl0IGlz
LgoKVGhhbmtzCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
ClZpcnR1YWxpemF0aW9uIG1haWxpbmcgbGlzdApWaXJ0dWFsaXphdGlvbkBsaXN0cy5saW51eC1m
b3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9s
aXN0aW5mby92aXJ0dWFsaXphdGlvbg==
