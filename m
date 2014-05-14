From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next PATCH 2/5] ixgbe: increase default TX ring buffer to
 1024
Date: Wed, 14 May 2014 14:28:24 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1724483B@AcuExch.aculab.com>
References: <20140514141545.20309.28343.stgit@dragon>
 <20140514141748.20309.83121.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Florian Westphal" <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	"Stephen Hemminger" <shemminger@vyatta.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"danieltt@kth.se" <danieltt@kth.se>,
	"zhouzhouyi@gmail.com" <zhouzhouyi@gmail.com>
To: 'Jesper Dangaard Brouer' <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45454 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751620AbaENO2f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 10:28:35 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 27522-07 for <netdev@vger.kernel.org>;
 Wed, 14 May 2014 15:28:25 +0100 (BST)
In-Reply-To: <20140514141748.20309.83121.stgit@dragon>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSmVzcGVyIERhbmdhYXJkIEJyb3Vlcg0KPiBVc2luZyBwa3RnZW4gSSdtIHNlZWluZyB0
aGUgaXhnYmUgZHJpdmVyICJwdXNoLWJhY2siLCBkdWUgVFggcmluZw0KPiBydW5uaW5nIGZ1bGwu
ICBUaHVzLCB0aGUgVFggcmluZyBpcyBhcnRpZmljaWFsbHkgbGltaXRpbmcgcGt0Z2VuLg0KPiAN
Cj4gRGlhZ25vc2UgdmlhICJldGh0b29sIC1TIiwgbG9vayBmb3IgInR4X3Jlc3RhcnRfcXVldWUi
IG9yICJ0eF9idXN5Ig0KPiBjb3VudGVycy4NCg0KSGF2ZSB5b3UgdHJpZWQgcmVkdWNpbmcgdGhl
IHR4IGludGVycnVwdCBtaXRpZ2F0aW9uIGRlbGF5Lg0KSXQgbWlnaHQganVzdCBiZSB0aGF0IHRo
ZSBlbmQgb2YgdHggaW50ZXJydXB0IGlzIGRlbGF5ZWQgdG9vIGxvbmcuDQoNCglEYXZpZA0KDQo=
