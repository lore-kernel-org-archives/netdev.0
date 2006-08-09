From: Christoph Hellwig <hch@infradead.org>
Subject: Re: 3945 driver using d80211
Date: Wed, 9 Aug 2006 18:26:17 +0100
Message-ID: <20060809172617.GA5431@infradead.org>
References: <44D901C9.6090304@linux.intel.com> <200608081440.48623.flamingice@sourmilk.net> <44D99558.1000507@sipsolutions.net> <200608090947.20291.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Mohamed Abbas <mabbas@linux.intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:26791 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751270AbWHIR0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 13:26:25 -0400
To: Michael Wu <flamingice@sourmilk.net>
Content-Disposition: inline
In-Reply-To: <200608090947.20291.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 09:47:15AM -0700, Michael Wu wrote:
> probe response handling to complete the picture. What other half-fullmac, 
> half-softmac card besides the other IPW cards splits card/host 802.11 duties 
> along those lines? What other splits between card and host are out there? I 
> would be very reluctant to make changes to the 802.11 stack to support 
> "fullmac" without evidence that other drivers need the change.

You need to support ipw2[12]00 anyway.
