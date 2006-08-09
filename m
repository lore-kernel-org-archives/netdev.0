From: Jeff Garzik <jeff@garzik.org>
Subject: Re: d80211 merge plans
Date: Wed, 09 Aug 2006 01:40:27 -0400
Message-ID: <44D9754B.3060909@garzik.org>
References: <200608090703.45651.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:18592 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965077AbWHIFkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 01:40:42 -0400
To: Michael Buesch <mb@bu3sch.de>,
	"John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <200608090703.45651.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> To heavily reduce maintainance burden I would like to see d80211
> going mainline as soon as possible, so that we can feature-freeze
> the softmac port of bcm43xx and reduce maintainance to next to zero
> there. So if people want freaky features, we simply point them
> to the d80211 port, which would coexist in mainline.
> 
> d80211 in mainline would clearly marked as experimental, for sure.
> Notes must be added for possibly breaking usermode interfaces.


Does it have active maintainers?

The DeviceScape people seem to have disappeared for months, except for a 
rare appearance recently by Jouni.

Did anyone ever come up with a list of why d80211 is superior?
What are the remaining d80211 issues?

	Jeff


