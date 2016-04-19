From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH v2 net-next 4/7] tcp: Make use of MSG_EOR flag in
 tcp_sendmsg
Date: Tue, 19 Apr 2016 09:47:13 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4A53D7@AcuExch.aculab.com>
References: <1461019569-3037369-1-git-send-email-kafai@fb.com>
	 <1461019569-3037369-5-git-send-email-kafai@fb.com>
 <1461021493.10638.131.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	"Soheil Hassas Yeganeh" <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.189]:58961 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbcDSJsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 05:48:23 -0400
In-Reply-To: <1461021493.10638.131.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IFNlbnQ6IDE5IEFwcmlsIDIwMTYgMDA6MTgNCi4uLg0KPiBN
U0dfRU9SIHNob3VsZCBub3QgZGVwZW5kIG9uIFNLQlRYX0FOWV9UU1RBTVANCj4gDQo+IFJlYWxs
eSwgc2ltcGx5IHVzaW5nIHNlbmQoZmQsIC4uLiwgbGVuLCBNU0dfRU9SKSBzaG91bGQgaW5zdHJ1
Y3QgVENQIHRvDQo+IG1hcmsgdGhlIGNvb2tlZCBza2IgYXMgYSBub24gY2FuZGlkYXRlIGZvciBm
dXR1cmUgY29hbGVzY2luZy4NCg0KSXNuJ3QgdGhhdCB2ZXJ5IHNpbWlsYXIgdG8gdGhlIGludmVy
c2Ugb2YgTVNHX01PUkU/DQpPciBhIHNlbmQgd2l0aCBOYWdsZSBkaXNhYmxlZD8NCg0KCURhdmlk
DQoNCg==
