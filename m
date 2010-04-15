From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/2] igbvf: dobule increment nr_frags
Date: Thu, 15 Apr 2010 11:05:17 -0700
Message-ID: <y2r9929d2391004151105pf07d6804ifbc14f25838a29c1@mail.gmail.com>
References: <4BC6BEFC.3010309@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, davem@davemloft.net
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4BC6BEFC.3010309@jp.fujitsu.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

MjAxMC80LzE1IEtva2kgU2FuYWdpIDxzYW5hZ2kua29raUBqcC5mdWppdHN1LmNvbT46Cj4gVGhl
cmUgaXMgbm8gbmVlZCB0byBpbmNyZW1lbnQgbnJfZnJhZ3MgYmVjYXN1ZSBza2JfZmlsbF9wYWdl
X2Rlc2MgaW5jcmVtZW50cwo+IGl0Lgo+Cj4gU2lnbmVkLW9mZi1ieTogS29raSBTYW5hZ2kgPHNh
bmFnaS5rb2tpQGpwLmZ1aml0c3UuY29tPgo+IC0tLQo+IMKgZHJpdmVycy9uZXQvaWdidmYvbmV0
ZGV2LmMgfCDCoCDCoDIgKy0KPiDCoDEgZmlsZXMgY2hhbmdlZCwgMSBpbnNlcnRpb25zKCspLCAx
IGRlbGV0aW9ucygtKQo+CgpUaGFua3MgSSBoYXZlIGFkZGVkIHRoaXMgcGF0Y2ggdG8gbXkgcXVl
dWUgb2YgcGF0Y2hlcy4KCi0tIApDaGVlcnMsCkplZmYKCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpE
b3dubG9hZCBJbnRlbCYjMTc0OyBQYXJhbGxlbCBTdHVkaW8gRXZhbApUcnkgdGhlIG5ldyBzb2Z0
d2FyZSB0b29scyBmb3IgeW91cnNlbGYuIFNwZWVkIGNvbXBpbGluZywgZmluZCBidWdzCnByb2Fj
dGl2ZWx5LCBhbmQgZmluZS10dW5lIGFwcGxpY2F0aW9ucyBmb3IgcGFyYWxsZWwgcGVyZm9ybWFu
Y2UuClNlZSB3aHkgSW50ZWwgUGFyYWxsZWwgU3R1ZGlvIGdvdCBoaWdoIG1hcmtzIGR1cmluZyBi
ZXRhLgpodHRwOi8vcC5zZi5uZXQvc2Z1L2ludGVsLXN3LWRldgpfX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fXwpFMTAwMC1kZXZlbCBtYWlsaW5nIGxpc3QKRTEw
MDAtZGV2ZWxAbGlzdHMuc291cmNlZm9yZ2UubmV0Cmh0dHBzOi8vbGlzdHMuc291cmNlZm9yZ2Uu
bmV0L2xpc3RzL2xpc3RpbmZvL2UxMDAwLWRldmVsClRvIGxlYXJuIG1vcmUgYWJvdXQgSW50ZWwm
IzE3NDsgRXRoZXJuZXQsIHZpc2l0IGh0dHA6Ly9jb21tdW5pdGllcy5pbnRlbC5jb20vY29tbXVu
aXR5L3dpcmVkCg==
