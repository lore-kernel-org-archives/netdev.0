From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/1 net-next] net: fec: enable pause frame to improve rx prefomance for 1G network
Date: Tue, 8 Jan 2013 13:32:11 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7104@saturn3.aculab.com>
References: <1357634609-4112-1-git-send-email-Frank.Li@freescale.com> <1357649564.29986.10.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <lznuaa@gmail.com>, <shawn.guo@linaro.org>, <B38611@freescale.com>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>, <s.hauer@pengutronix.de>
To: "Ben Hutchings" <bhutchings@solarflare.com>,
	"Frank Li" <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45950 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756248Ab3AHNeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2013 08:34:05 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14412-09 for <netdev@vger.kernel.org>;
 Tue,  8 Jan 2013 13:34:00 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1357649564.29986.10.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBJZiB0aGUgbWVkaXVtIHN1cHBvcnRzIGF1dG9uZW9nLCB1c2UgbWlpX2FkdmVydGlzZV9mbG93
Y3RybCgpIGluDQo+IHNldF9wYXVzZXBhcmFtIHRvIHVwZGF0ZSBwYXVzZSBmcmFtZSBhZHZlcnRp
c2luZyBhbmQgdGhlbiByZXN0YXJ0DQo+IGF1dG9uZWcuDQoNCklzbid0IGF1dG9uZWcgY29udGlu
dW91cz8NCkluIHdoaWNoIGNhc2UgeW91IGp1c3QgbmVlZCB0byBtb25pdG9yIHRoZSByZXNwb25z
ZSByZWdpc3Rlci4NCk1vbml0b3JpbmcgTUlJIHJlZ2lzdGVycyBpcyB1c3VhbGx5IGEgY29tcGxl
dGUgUElUQSB0aG91Z2gNCihkdWUgdG8gdGhlIHJlcXVpcmVtZW50cyBmb3IgZGVsYXlzIGR1cmlu
ZyB0aGUgYml0LWJhc2hpbmcpLg0KDQoJRGF2aWQNCg0K
