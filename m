From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 097/101] revert "drivers/net/tulip/dmfe: support basic
 carrier detection"
Date: Wed, 7 Mar 2007 19:06:46 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0703071906060.10832@woody.linux-foundation.org>
References: <20070307171035.150802805@mini.kroah.org>
 <20070307171657.461008445@mini.kroah.org>  <20070307101444.52cb2146@freekitty>
 <1173321712.12017.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org,
	stable@kernel.org, jeff@garzik.org,
	Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	thomas@archlinux.org, val_henson@linux.intel.com,
	samuel.thibault@ens-lyon.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:45590 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751134AbXCHDJY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 22:09:24 -0500
In-Reply-To: <1173321712.12017.8.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 7 Mar 2007, Dan Williams wrote:
> 
> Definitely right.  If it doesn't work for your card, it needs to be
> fixed for your card.

Well, regressions are regressions. And they are a *lot* more important 
than any new features. If it doesn't work, it gets reverted.

		Linus
