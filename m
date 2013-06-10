From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [BOUNTY] Need a Working Driver Brought Up From 2.6.29 to
 2.6.34. Will Pay.
Date: Mon, 10 Jun 2013 16:00:30 +0100
Message-ID: <1370876430.1933.7.camel@bwh-desktop.uk.level5networks.com>
References: <20130609204121.28418.qmail@ballcam.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <kernel-dev@ballcam.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24415 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048Ab3FJPAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 11:00:34 -0400
In-Reply-To: <20130609204121.28418.qmail@ballcam.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-09 at 15:41 -0500, kernel-dev@ballcam.com wrote:
> I have an OEM Driver that works Excellent under 2.6.29.
> 
> I need it working in 2.6.34

Which is itself about 3.5 years old now... is this really a new message
or did you accidentally re-send it?

[...]
> After this issue is solved the project will go on IndieGoGo,
> and I will take it to the next level. For now I can pay,
> but I am not a MegaCorp.   
> 
> I can certainly work with anyone offline, but please
> respond here if appropriate. 

This isn't really the appropriate list for offers to hire developers.

> I do believe the end product can, and probably should
> be included in the 2.6.34 mainline release.

If you want a driver to be included in-tree, the first possible release
(if it was ready today) would be Linux 3.11.  New drivers are never
backported to the stable branches at kernel.org, though they are
commonly backported by distributions.  I think the LTSI 3.4 branch also
accepts new drivers.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
