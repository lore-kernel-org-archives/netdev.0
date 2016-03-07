From: Kyeong Yoo <Kyeong.Yoo@alliedtelesis.co.nz>
Subject: Re: [net-next PATCH v2] net_sched: dsmark: use qdisc_dequeue_peeked()
Date: Mon, 7 Mar 2016 04:06:49 +0000
Message-ID: <1457323609.26320.12.camel@kyeongy-dl>
References: <1457000719.30212.3.camel@kyeongy-dl>
	 <20160306.224921.2002681200914411743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:53322 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbcCGEGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 23:06:55 -0500
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id BE463806CB
	for <netdev@vger.kernel.org>; Mon,  7 Mar 2016 17:06:51 +1300 (NZDT)
In-Reply-To: <20160306.224921.2002681200914411743.davem@davemloft.net>
Content-Language: en-US
Content-ID: <08F8B852C81B634FB1EA75A4DA1703B7@atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SSB3aWxsIHVwbG9hZCBuZXcgcGF0Y2ggc29vbi4NCkt5ZW9uZw0KDQpPbiBTdW4sIDIwMTYtMDMt
MDYgYXQgMjI6NDkgLTA1MDAsIERhdmlkIE1pbGxlciB3cm90ZToNCj4gRnJvbTogS3llb25nIFlv
byA8S3llb25nLllvb0BhbGxpZWR0ZWxlc2lzLmNvLm56Pg0KPiBEYXRlOiBUaHUsIDMgTWFyIDIw
MTYgMTA6MjU6MTkgKzAwMDANCi4uLg0KPiBZb3VyIHBhdGNoIGlzIGNvcnJ1cHRlZCBieSB5b3Vy
IGVtYWlsIGNsaWVudCwgaXQgaGFzIE1TLURPUyBzdHlsZQ0KPiBuZXdsaW5lcywgZXRjLg0KDQo=
