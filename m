From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [PATCH net 1/3] kref: add kref_sub_return
Date: Wed, 12 Feb 2014 20:25:48 -0500
Message-ID: <20140213012548.GA20953@logfs.org>
References: <1392222846-26699-1-git-send-email-mst@redhat.com>
	<1392222846-26699-2-git-send-email-mst@redhat.com>
	<20140212165630.GA22991@kroah.com>
	<20140212.190637.328045386111912135.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: virtio-dev@lists.oasis-open.org, anatol.pomozov@gmail.com, mst@redhat.com,
	gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, qinchuanyu@huawei.com
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20140212.190637.328045386111912135.davem@davemloft.net>
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

T24gV2VkLCAxMiBGZWJydWFyeSAyMDE0IDE5OjA2OjM3IC0wNTAwLCBEYXZpZCBNaWxsZXIgd3Jv
dGU6Cj4gCj4gSXQgaXNuJ3QgYmVpbmcgdXNlZCB0byBkZXRlcm1pbmUgd2hlbiB0byBkZXN0cm95
IHRoaW5ncy4KPiAKPiBUaGV5IHVzZSBpdCB0byBhcyBhIGhldXJpc3RpYyBvZiB3aGVuIHRvIHRy
aWdnZXIgcG9sbGluZy4KPiAKPiBFYWNoIHVidWYgYXR0YWNoZWQgZ2V0cyBhIGtyZWYgdG8gdGhl
IGhpZ2hlciBsZXZlbCB2aXJ0aW9fbmV0IGJ1ZmZlcgo+IGhvbGRpbmcgb2JqZWN0LCB0aGV5IHdh
bnQgdG8gdHJpZ2dlciBwb2xsaW5nIHdoZW4gdGhhdCByZWZlcmVuY2UgZHJvcHMKPiB0byAxIG9y
IGxvd2VyLgo+IAo+IFJpZ2h0IG5vdyB0aGV5IGFyZSByZWFkaW5nIHRoZSBhdG9taWMgcmVmY291
bnQgZGlyZWN0bHksIHdoaWNoCj4gSSB0aGluayBpcyBtdWNoIHdvcnNlIHRoYW4gdGhpcyBoZWxw
ZXIuCgpJIGRpc2FncmVlLiAgUmVhZGluZyB0aGUgcmVmY291bnQgZGlyZWN0bHkgaXMgbGVhdmlu
ZyBub29uZSB1bmRlciBhbnkKaWxsdXNpb24gdGhhdCB0aGlzIG1pZ2h0IGJlIGEgZ29vZCBpZGVh
LgoKSsO2cm4KCi0tClZpY3RvcnkgaW4gd2FyIGlzIG5vdCByZXBldGl0aW91cy4KLS0gU3VuIFR6
dQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpWaXJ0dWFs
aXphdGlvbiBtYWlsaW5nIGxpc3QKVmlydHVhbGl6YXRpb25AbGlzdHMubGludXgtZm91bmRhdGlv
bi5vcmcKaHR0cHM6Ly9saXN0cy5saW51eGZvdW5kYXRpb24ub3JnL21haWxtYW4vbGlzdGluZm8v
dmlydHVhbGl6YXRpb24=
