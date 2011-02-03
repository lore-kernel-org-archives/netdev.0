From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v4 0/2] iproute2: support for device groups
Date: Wed, 2 Feb 2011 16:14:17 -0800
Message-ID: <20110202161417.2a3d10a4@nehalam>
References: <1296671021-24421-1-git-send-email-ddvlad@rosedu.org>
	<4D49E252.1080006@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Vlad Dogaru <ddvlad@rosedu.org>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60731 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755388Ab1BCAOT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 19:14:19 -0500
In-Reply-To: <4D49E252.1080006@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 Feb 2011 00:01:38 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Am 02.02.2011 19:23, schrieb Vlad Dogaru:
> > This patch series adds userspace support for network device groups.
> > There is support for setting device groups, listing only interfaces of a
> > specific group, and setting basic device parameters for all interfaces
> > in a group.
> > 
> > Changes since version 3:
> >  * drop devgroup keyword. There is a single keyword for specifying
> >    groups now.
> >  * store group names internally as a hash, similar to routing table
> >    names. This is more efficient for batch mode operations
> 
> Looks good to me, thanks.

Will apply after 2.6.38 is released.

-- 
