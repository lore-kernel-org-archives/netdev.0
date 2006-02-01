From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [RFC] Backward compatibility and WAN netdev configuration
Date: Wed, 01 Feb 2006 19:33:47 +0100
Message-ID: <m3r76n3p4k.fsf@defiant.localdomain>
References: <m3psm7tksr.fsf@defiant.localdomain>
	<20060201144917.GA7644@wonderland.linux.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422863AbWBASdy@vger.kernel.org>
To: md@Linux.IT (Marco d'Itri)
In-Reply-To: <20060201144917.GA7644@wonderland.linux.it> (Marco d'Itri's message of "Wed, 1 Feb 2006 15:49:17 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

md@Linux.IT (Marco d'Itri) writes:

> Why you cannot support autoloading the modules when a specific protocol
> is needed?

I probably could but it would complicate things a bit - currently only
the protocol module knows about existence of its protocol.

I will look at it, though. Thanks.
-- 
Krzysztof Halasa
