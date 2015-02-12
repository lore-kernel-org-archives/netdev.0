From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: netfilter: Move sysctl-specific error
 code inside #ifdef
Date: Thu, 12 Feb 2015 08:45:11 -0800 (PST)
Message-ID: <20150212.084511.1589856092812725449.davem@davemloft.net>
References: <1423750647-30389-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1423750647-30389-1-git-send-email-geert@linux-m68k.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

RnJvbTogR2VlcnQgVXl0dGVyaG9ldmVuIDxnZWVydEBsaW51eC1tNjhrLm9yZz4NCkRhdGU6IFRo
dSwgMTIgRmViIDIwMTUgMTU6MTc6MjcgKzAxMDANCg0KPiBJZiBDT05GSUdfU1lTQ1RMPW46DQo+
IA0KPiAgICAgbmV0L2JyaWRnZS9icl9uZXRmaWx0ZXIuYzogSW4gZnVuY3Rpb24goWJyX25ldGZp
bHRlcl9pbml0ojoNCj4gICAgIG5ldC9icmlkZ2UvYnJfbmV0ZmlsdGVyLmM6OTk2OiB3YXJuaW5n
OiBsYWJlbCChZXJyMaIgZGVmaW5lZCBidXQgbm90IHVzZWQNCj4gDQo+IE1vdmUgdGhlIGxhYmVs
IGFuZCB0aGUgY29kZSBhZnRlciBpdCBpbnNpZGUgdGhlIGV4aXN0aW5nICNpZmRlZiB0byBnZXQN
Cj4gcmlkIG9mIHRoZSB3YXJuaW5nLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogR2VlcnQgVXl0dGVy
aG9ldmVuIDxnZWVydEBsaW51eC1tNjhrLm9yZz4NCg0KQXBwbGllZCwgdGhhbmtzLg0K
