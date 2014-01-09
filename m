From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Use of 'SIOCDEVPRIVATE' in ethernet drivers.
Date: Thu, 9 Jan 2014 21:09:35 +0000
Message-ID: <1389301775.2025.43.camel@bwh-desktop.uk.level5networks.com>
References: <124064C45E1FC84193A69A61ED3A1F46E22D07@AVMB1.qlogic.org>
	 <20140107.140520.1985936966889106257.davem@davemloft.net>
	 <124064C45E1FC84193A69A61ED3A1F46E230D6@AVMB1.qlogic.org>
	 <20140107154456.7e5af377@nehalam.linuxnetplumber.net>
	 <124064C45E1FC84193A69A61ED3A1F46E2331F@AVMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Giri Reddy <giri.reddy@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26633 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753095AbaAIVJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 16:09:39 -0500
In-Reply-To: <124064C45E1FC84193A69A61ED3A1F46E2331F@AVMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-08 at 16:02 +0000, Giri Reddy wrote:
> Thanks for the input. I will explore the 'ethtool' option. We will have
> multiple control frames exchanged between user space and kernel for
> every flash update operation, most of this will be proprietary stuff
> that will get exchanged - I will explore how to provide a generic
> interface for that.
[...]

What you need to do beyond read, write, erase and reset?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
