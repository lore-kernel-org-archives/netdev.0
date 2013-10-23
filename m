From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] netpoll: fix rx_hook() interface by passing the skb
Date: Wed, 23 Oct 2013 12:18:32 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73A4@saturn3.aculab.com>
References: <20131022.025038.1046903740187748879.davem@davemloft.net> <1382431715-3128-1-git-send-email-antonio@meshcoding.com> <AE90C24D6B3A694183C094C60CF0A2F6026B739B@saturn3.aculab.com> <20131022101127.GJ1544@neomailbox.net> <AE90C24D6B3A694183C094C60CF0A2F6026B739F@saturn3.aculab.com> <20131022171314.GL1544@neomailbox.net> <AE90C24D6B3A694183C094C60CF0A2F6026B73A1@saturn3.aculab.com> <20131023102848.GB1535@neomailbox.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Antonio Quartulli" <antonio@meshcoding.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:36524 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752441Ab3JWLTz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Oct 2013 07:19:55 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14735-01 for <netdev@vger.kernel.org>;
 Wed, 23 Oct 2013 12:19:54 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20131023102848.GB1535@neomailbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBNeSBpZGVhIGlzIHRvIHVzZSB0aGUgZm9sbG93aW5nIEFQSToNCj4gDQo+IHJ4X3NrYl9ob29r
KHN0cnVjdCBuZXRwb2xsICpucCwgaW50IHNvdXJjZSwgc3RydWN0IHNrX2J1ZmYgKnNrYiwgaW50
IGxlbik7DQo+IA0KPiBBbnkgc3VnZ2VzdGlvbiBvciBvYmplY3Rpb24/DQoNCkRvbid0IHlvdSBu
ZWVkIHRvIHBhc3MgdGhlIG9mZnNldCBvZiB0aGUgdWRwIGRhdGE/DQoNCglEYXZpZA0KDQo=
