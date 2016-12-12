From: "Jorgen S. Hansen" <jhansen@vmware.com>
Subject: Re: [PATCH v3 2/4] vhost-vsock: add pkt cancel capability
Date: Mon, 12 Dec 2016 10:37:26 +0000
Message-ID: <426F96AC-2E7C-4BEC-A3D3-7D8A97FDD51D@vmware.com>
References: <1481217156-7160-1-git-send-email-bergwolf@gmail.com>
	<1481217156-7160-2-git-send-email-bergwolf@gmail.com>
	<1481217156-7160-3-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	David Miller <davem@davemloft.net>, Stefan Hajnoczi <stefanha@redhat.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: Peng Tao <bergwolf@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481217156-7160-3-git-send-email-bergwolf@gmail.com>
Content-Language: en-US
Content-ID: <92C3B3E26B5D6441A3FEC70C28A2B06C@namprd05.prod.outlook.com>
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

DQo+IE9uIERlYyA4LCAyMDE2LCBhdCA2OjEyIFBNLCBQZW5nIFRhbyA8YmVyZ3dvbGZAZ21haWwu
Y29tPiB3cm90ZToNCj4gDQo+IC0tLSBhL2luY2x1ZGUvbmV0L2FmX3Zzb2NrLmgNCj4gKysrIGIv
aW5jbHVkZS9uZXQvYWZfdnNvY2suaA0KPiBAQCAtMTAwLDYgKzEwMCw5IEBAIHN0cnVjdCB2c29j
a190cmFuc3BvcnQgew0KPiAJdm9pZCAoKmRlc3RydWN0KShzdHJ1Y3QgdnNvY2tfc29jayAqKTsN
Cj4gCXZvaWQgKCpyZWxlYXNlKShzdHJ1Y3QgdnNvY2tfc29jayAqKTsNCj4gDQo+ICsJLyogQ2Fu
Y2VsIHBhY2tldHMgYmVsb25naW5nIHRoZSBzYW1lIHZzb2NrICovDQoNCkhvdyBhYm91dCDigJwv
KiBDYW5jZWwgYWxsIHBlbmRpbmcgcGFja2V0cyBzZW50IG9uIHZzb2NrLiAqL+KAnCA/IA0KDQo+
ICsJaW50ICgqY2FuY2VsX3BrdCkoc3RydWN0IHZzb2NrX3NvY2sgKnZzayk7DQo+ICsNCj4gCS8q
IENvbm5lY3Rpb25zLiAqLw0KPiAJaW50ICgqY29ubmVjdCkoc3RydWN0IHZzb2NrX3NvY2sgKik7
DQo+IA0KPiAtLSANCj4gMi43LjQNCj4gDQoNClRoYW5rcywNCkrDuHJnZW4KX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KVmlydHVhbGl6YXRpb24gbWFpbGlu
ZyBsaXN0ClZpcnR1YWxpemF0aW9uQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8v
bGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL3ZpcnR1YWxpemF0aW9u
