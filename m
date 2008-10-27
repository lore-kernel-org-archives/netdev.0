From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: bisected: 2.6.28-rc broke my iwl4965 wireless
Date: Mon, 27 Oct 2008 10:33:03 -0700
Message-ID: <20081027103303.0fed7aa0@infradead.org>
References: <20081025222208.1d2a2c8b@infradead.org>
	<20081027163812.GB6377@tesla>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Luis Rodriguez <Luis.Rodriguez@Atheros.com>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50444 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbYJ0Rcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 13:32:47 -0400
In-Reply-To: <20081027163812.GB6377@tesla>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Oct 2008 09:38:12 -0700
"Luis R. Rodriguez" <lrodriguez@atheros.com> wrote:

> Additionally if the old behaviour is desired for now (until
> distributions catch up and add CRDA) CONFIG_WIRELESS_OLD_REGULATORY
> can be enabled and you'll get the old behaviour of defaulting to
> country "US".
> 
> Please let me know if there are any issues.

the point is that this compatibility behavior should have been the
default... since it'll be at least 6 months before current distros will
even ship the userland..


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
