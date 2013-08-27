From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next RFC 6/7] i40evf: init code and hardware support
Date: Tue, 27 Aug 2013 18:42:37 +0100
Message-ID: <1377625357.13272.54.camel@bwh-desktop.uk.level5networks.com>
References: <1377233609-11627-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1377233609-11627-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>,
	Mitch A Williams <mitch.a.williams@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16688 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366Ab3H0Rml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 13:42:41 -0400
In-Reply-To: <1377233609-11627-7-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-22 at 21:53 -0700, Jeff Kirsher wrote:
[...]
> Intel does wish to maintain exclusive Copyright to these files, and will
> work with the community to implement requested changes or transfer
> Copyright for larger patches.  If you do see an issue with this code
> please email us and we will address any concerns in a timely manner.
[...]

I wonder why this is thought to be necessary.  I've never heard of
copyright assignment conditions being accepted in the Linux kernel.

Some Linux drivers are dual-licenced under a permissive licence and GPL,
and all contributions to them presumably also have to be dual-licenced.
It seems like that would allow you to retain the ability to reuse the
core hardware code on other operating systems and under proprietary
licences, even with copyrightable contributions from others.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
