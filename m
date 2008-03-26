From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/8] New driver "sfc" for Solarstorm SFC4000 controller (try #8)
Date: Wed, 26 Mar 2008 11:58:19 +0000
Message-ID: <20080326115818.GD24160@solarflare.com>
References: <20080324102936.GZ24160@solarflare.com> <20080324.132253.110641003.davem@davemloft.net> <20080325125421.GB24160@solarflare.com> <20080325.163740.38242006.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:59031 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752849AbYCZL6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 07:58:41 -0400
Content-Disposition: inline
In-Reply-To: <20080325.163740.38242006.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Tue, 25 Mar 2008 12:54:23 +0000
> 
> > Would you object to our using this test until the default definition exists?
> 
> I'm trying to tell you that you should submit first a
> patch that adds the default definition, as part of
> your patch set.  Instead of papering around this
> problem and waiting for the non-existent "someone else"
> to do the work.

Oh, I'm not waiting.  I have prepared a patch for this.  But it seems
out-of-scope for networking and we'd rather not have the driver blocked
on acceptance of that, so I'll take out the topology check for now.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
