From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH v2] ethtool: check size of user memory before copying
 strings and stats
Date: Wed, 2 Mar 2016 01:11:53 +0000
Message-ID: <1456881113.9520.24.camel@intel.com>
References: <1456871112-14103-1-git-send-email-jacob.e.keller@intel.com>
	 <1456877540.3098.162.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"Rustad, Mark D" <mark.d.rustad@intel.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"mirq-linux@rere.qmqm.pl" <mirq-linux@rere.qmqm.pl>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
To: "ben@decadent.org.uk" <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:16776 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755101AbcCBBMN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 20:12:13 -0500
In-Reply-To: <1456877540.3098.162.camel@decadent.org.uk>
Content-Language: en-US
Content-ID: <FE170C8E4B846B4885A90D05E496CFA9@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gV2VkLCAyMDE2LTAzLTAyIGF0IDAwOjEyICswMDAwLCBCZW4gSHV0Y2hpbmdzIHdyb3RlOg0K
PiBOQUssIGV0aHRvb2wgaXMgbm90IHRoZSBvbmx5IGNvbnN1bWVyIG9mIHRoZSBldGh0b29sIEFQ
SS4gwqBIb3cgbWFueQ0KPiB0aW1lcyBkbyBJIGhhdmUgdG8gcmVwZWF0IG15c2VsZj8NCj4gDQo+
IEJlbi4NCj4gDQoNCk9rLCBzbyBlc3NlbnRpYWxseSBmb3JjaW5nIGRyaXZlcnMgdG8gcmVxdWly
ZSBzdGF0aWMgc2V0cyBmb3IgdGhlDQp2YXJpb3VzIHN0YXRzL3N0cmluZ3MvZXRjPw0KDQo6KA0K
DQpXaWxsIGhhdmUgcGF0Y2hlcyB0byBjbGVhbnVwIGZtMTBrIGZvciB0aGlzIHRoZW4uDQoNClJl
Z2FyZHMsDQpKYWtl
