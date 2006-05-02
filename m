From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: forcedeth driver NAPI?
Date: Tue, 2 May 2006 22:06:18 +0200
Message-ID: <20060502200618.GA28847@electric-eye.fr.zoreil.com>
References: <200605021549.47719.netdev@axxeo.de> <20060502121151.63786a86@localhost.localdomain> <200605022135.53580.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Ingo Oeser <netdev@axxeo.de>,
	Manfred Spraul <manfred@colorfullife.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:55508 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751266AbWEBUIJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 May 2006 16:08:09 -0400
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <200605022135.53580.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen <ak@suse.de> :
> On Tuesday 02 May 2006 21:11, Stephen Hemminger wrote:
[napi for forcedeth]
> Making it support netpoll would be nice too.

<wishlist>
Disable/resume the device with something less gross than
http://bugzilla.kernel.org/show_bug.cgi?id=6398
</wishlist>

-- 
Ueimor
