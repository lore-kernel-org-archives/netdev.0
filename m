From: Jeff Garzik <jeff@garzik.org>
Subject: Re: cfg80211/nl80211/WE
Date: Thu, 02 Nov 2006 03:59:05 -0500
Message-ID: <4549B359.1070104@garzik.org>
References: <20061026050416.GB14199@havoc.gtf.org>	 <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net>	 <20061101112805.246e1b3b@griffin.suse.cz>	 <20061101142022.GC21668@tuxdriver.com> <4548E7F7.7030100@linux.intel.com>	 <45493C09.9050707@garzik.org> <45494E51.7070707@linux.intel.com>	 <45495E27.6090500@garzik.org> <1162457341.3241.15.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Ketrenos <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Simon Barber <simon@devicescape.com>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>,
	Linus Torvalds <torvalds@osdl.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:8621 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1752746AbWKBI7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 03:59:42 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1162457341.3241.15.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> My goal is to remove WE from *all* drivers, even from the ancient
> pre-802.11 and early 802.11 fullmac drivers, and leave WE merely as
> another userspace interface for cfg80211, albeit with limitations that
> the netlink interface nl80211 doesn't have.

Sounds good to me...

	Jeff


