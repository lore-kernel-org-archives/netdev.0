From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: 2.6.34.1, e1000e, VLAN's and kernel BUG
Date: Wed, 21 Jul 2010 17:38:07 +0300
Message-ID: <201007211738.07605.nuclearcat@nuclearcat.com>
References: <201007211703.23093.nuclearcat@nuclearcat.com> <1279722611.2452.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:57349 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932131Ab0GUOi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 10:38:28 -0400
In-Reply-To: <1279722611.2452.49.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 21 July 2010 17:30:11 Eric Dumazet wrote:
> > 
> >  66 89 41 7a <83> 3b 00 0f 84 a0 00 00 00 8d 7b 5c 89 f8 e8 5c de 05 00
> >  f6 43
> > 
> > --
> 
> You might need patch provided by commit b0f77d0eae0c58a5a
> 
> http://git2.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;
> h=b0f77d0eae0c58a5a
Thanks, i will try it.
