From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next V4 00/15] net: introduce upper device lists
 and remove dev->master
Date: Wed, 02 Jan 2013 02:54:20 -0800 (PST)
Message-ID: <20130102.025420.1993175980232815756.davem@davemloft.net>
References: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, edumazet@google.com,
	bhutchings@solarflare.com, faisal.latif@intel.com,
	shemminger@vyatta.com, fbl@redhat.com, roland@kernel.org,
	sean.hefty@intel.com, hal.rosenstock@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, divy@chelsio.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com, kaber@trash.net,
	ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	ebiederm@xmission.com, joe@perches.com, amwang@redhat.com,
	nhorman@tuxdriver.com, john.r.fastabend@intel.com,
	pablo@netfilter.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40253 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134Ab3ABKyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2013 05:54:22 -0500
In-Reply-To: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQpUaGlzIHBhdGNoIHNldCBicmVha3MgdGhlIGJ1aWxkOg0KDQpkcml2ZXJzL2luZmluaWJhbmQv
aHcvbmVzL25lc19jbS5jOiBJbiBmdW5jdGlvbiChbmVzX2FkZHJfcmVzb2x2ZV9uZWlnaKI6DQpk
cml2ZXJzL2luZmluaWJhbmQvaHcvbmVzL25lc19jbS5jOjEzNDM6MzogZXJyb3I6IGltcGxpY2l0
IGRlY2xhcmF0aW9uIG9mIGZ1bmN0aW9uIKFuZXRkZXZfdW5pcXVlX3VwcGVyX2Rldl9nZXSiDQoN
CkkgY291bGQgZ2l2ZSB5b3UgYSBoYXJkIHRpbWUgYW5kIHNheSB0aGF0IGFueSB0aW1lIHlvdSB0
b3VjaCBhIGNvcmUNCmhlYWRlciBmaWxlIHlvdSBtdXN0IGRvIHNvbWV0aGluZyBhdCBsZWFzdCBh
cHByb3hpbWF0aW5nIGFuDQphbGxtb2Rjb25maWcgYnVpbGQuDQoNCkJ1dCBpbiB0aGlzIGNhc2Us
IGl0IGlzIGNsZWFyIHRoYXQgeW91IGRpZG4ndCBldmVuIHRlc3QgdGhlIGZpbmFsDQpwYXRjaCBz
ZXQgd2l0aCB0aGlzIHNwZWNpZmljIGluZmluaWJhbmQgZHJpdmVyIGVuYWJsZWQuDQoNClRoYXQn
cyByZWFsbHkgZGlzYXBwb2ludGluZy4NCg==
