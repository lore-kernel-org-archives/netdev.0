From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: non-root, non-real network manipulation for netconf testing
Date: Tue, 3 Jun 2008 11:47:10 +0100
Message-ID: <20080603104709.GB18161@solarflare.com>
References: <20080603080529.GA9010@lapse.madduck.net> <20080603100513.GA18161@solarflare.com> <20080603102050.GA14461@lapse.madduck.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev discussion list <netdev@vger.kernel.org>,
	netconf developers list <netconf-devel@lists.alioth.debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:42964 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752696AbYFCKrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 06:47:23 -0400
Content-Disposition: inline
In-Reply-To: <20080603102050.GA14461@lapse.madduck.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

martin f krafft wrote:
> also sprach Ben Hutchings <bhutchings@solarflare.com> [2008.06.03.1205 +0200]:
> > Have you considering running the tests in User-Mode Linux or some
> > other kind of virtualised environment?
> 
> Yes, but that would require root rights as well, and quite a lot of
> setup, making it pretty unlikely that passerby developers would run
> tests, or allowing me to run the tests automatically on build
> daemons.

I don't believe that's the case for UML.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
