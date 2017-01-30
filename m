From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [PATCH 0/2] xen/net: limit number of tx/rx queues
Date: Sun, 29 Jan 2017 21:55:23 -0500
Message-ID: <7b27cfa9-fbda-1c05-c6f5-1519e3fce5ef@oracle.com>
References: <20170110133252.5346-1-jgross@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: paul.durrant@citrix.com, wei.liu2@citrix.com
To: Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org,
 xen-devel@lists.xenproject.org, netdev@vger.kernel.org
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <20170110133252.5346-1-jgross@suse.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

CgpPbiAwMS8xMC8yMDE3IDA4OjMyIEFNLCBKdWVyZ2VuIEdyb3NzIHdyb3RlOgo+IFRoZSBYZW4g
bmV0d29yayBmcm9udGVuZC9iYWNrZW5kIHN1cHBvcnRzIG11bHRpcGxlIHR4L3J4IHF1ZXVlcyBm
b3Igb25lCj4gdmlydHVhbCBpbnRlcmZhY2UuIFRoZSBudW1iZXIgb2YgcXVldWVzIHN1cHBvcnRl
ZCBieSB0aGUgYmFja2VuZCBpcwo+IHNldCB0byB0aGUgbnVtYmVyIG9mIGNwdXMgb2YgdGhlIGJh
Y2tlbmQgZHJpdmVyIGRvbWFpbiAodXN1YWxseSBkb20wKQo+IGFuZCB0aGUgbnVtYmVyIG9mIHF1
ZXVlcyByZXF1ZXN0ZWQgYnkgdGhlIGZyb250ZW5kIGlzIGxpbWl0ZWQgYnkgdGhlCj4gbnVtYmVy
IG9mIHZjcHVzIG9mIHRoZSByZWxhdGVkIGd1ZXN0Lgo+Cj4gT24gbGFyZ2Ugc3lzdGVtcyB0aGlz
IGNhbiBsZWFkIHRvIHJpZGljdWxvdXMgbGFyZ2UgbnVtYmVyIG9mIHF1ZXVlcwo+IGV4aGF1c3Rp
bmcgdGhlIHJlcXVpcmVkIG51bWJlciBvZiBncmFudCBwYWdlcyByYXRoZXIgcXVpY2suCj4KPiBU
byBhdm9pZCB0aGlzIGxpbWl0IHRoZSBkZWZhdWx0IG1heGltdW0gb24gYm90aCBzaWRlcyB0byA4
LiBCb3RoCj4gZnJvbnRlbmQgYW5kIGJhY2tlbmQgbWF4aW11bSBjYW4gYmUgaW5kaXZpZHVhbGx5
IHR1bmVkIHZpYSBtb2R1bGUKPiBwYXJhbWV0ZXJzLgo+Cj4gSnVlcmdlbiBHcm9zcyAoMik6Cj4g
ICB4ZW4vbmV0ZnJvbnQ6IHNldCBkZWZhdWx0IHVwcGVyIGxpbWl0IG9mIHR4L3J4IHF1ZXVlcyB0
byA4Cj4gICB4ZW4vbmV0YmFjazogc2V0IGRlZmF1bHQgdXBwZXIgbGltaXQgb2YgdHgvcnggcXVl
dWVzIHRvIDgKPgo+ICBkcml2ZXJzL25ldC94ZW4tbmV0YmFjay9uZXRiYWNrLmMgfCA2ICsrKyst
LQo+ICBkcml2ZXJzL25ldC94ZW4tbmV0ZnJvbnQuYyAgICAgICAgfCA2ICsrKystLQo+ICAyIGZp
bGVzIGNoYW5nZWQsIDggaW5zZXJ0aW9ucygrKSwgNCBkZWxldGlvbnMoLSkKPgoKQXBwbGllZCB0
byBmb3ItbGludXMtNC4xMQoKLWJvcmlzCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fXwpYZW4tZGV2ZWwgbWFpbGluZyBsaXN0Clhlbi1kZXZlbEBsaXN0cy54
ZW4ub3JnCmh0dHBzOi8vbGlzdHMueGVuLm9yZy94ZW4tZGV2ZWwK
