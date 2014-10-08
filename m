From: Rasesh Mody <rasesh.mody@qlogic.com>
Subject: RE: [PATCH net] bna: page allocation during interrupts to use a
 mempool.
Date: Wed, 8 Oct 2014 21:28:34 +0000
Message-ID: <2552F74A0BCCBE4DBE2AD218C81B2811C6399B@avmb3.qlogic.org>
References: <alpine.DEB.2.00.1409271631530.26069@ware.dreamhost.com>
	   <20140929092833.6c2cb7e9@urahara>
	   <262CB373A6D1F14F9B81E82F74F77D5A4704FAE7@avmb2.qlogic.org>
	   <alpine.DEB.2.00.1410061850120.5129@ware.dreamhost.com>
	  <1412646735.11091.93.camel@edumazet-glaptop2.roam.corp.google.com>
	  <alpine.DEB.2.00.1410061956410.7392@ware.dreamhost.com>
	 <1412651746.11091.98.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.00.1410071746230.3503@ware.dreamhost.com>
 <1412731718.11091.175.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Wheeler <netdev@lists.ewheeler.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:58785 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754073AbaJHV3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 17:29:39 -0400
In-Reply-To: <1412731718.11091.175.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkgRXJpYyBXaGVlbGVyLCBFcmljIER1bWF6ZXQsDQoNCldlJ2xsIHRyeSB0byByZXByb2R1Y2Ug
dGhlIGlzc3VlIGluLWhvdXNlIHRvIGZpbmQgbW9yZSBhYm91dCB0aGUgcm9vdCBjYXVzZSBvZiB0
aGUgZmFpbHVyZSBhbmQgd29yayBvbiBwb3NzaWJsZSBzb2x1dGlvbi4NCg0KVGhhbmtzLA0KLVJh
c2VzaA0K
