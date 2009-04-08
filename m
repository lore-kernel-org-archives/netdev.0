From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: sky2: early oops in pci_vpd_truncate
Date: Wed, 08 Apr 2009 13:15:50 -0700
Message-ID: <1239221750.3425.1.camel@brick>
References: <1238803819.3893.3.camel@brick> <20090403180306.44de0324@hobbes>
	 <1238815934.3893.4.camel@brick> <20090406112917.54c864ee@hobbes>
	 <1239054120.13299.0.camel@brick> <20090408120005.GB768@elte.hu>
	 <20090408094756.1951cec8@hobbes>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:23010 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbZDHUPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 16:15:54 -0400
Received: by rv-out-0506.google.com with SMTP id f9so273860rvb.1
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2009 13:15:53 -0700 (PDT)
In-Reply-To: <20090408094756.1951cec8@hobbes>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-04-08 at 09:47 -0700, Jesse Barnes wrote:
> On Wed, 8 Apr 2009 14:00:05 +0200
> Ingo Molnar <mingo@elte.hu> wrote:
> > I still have the revert - can i revert the revert from -tip now, 
> > it's all fixed in .30-rc1, right?
> 
> Yeah Linus pulled the fix, hopefully Harvey can confirm that things are
> working now.
> 

Well, now I'm hitting the invalid module format problem that seems to
have hit some others...so it's made it past the sky2 bits at least.

Rather busy right now, just checking in every few days with mainline
to see what's (still) broken. ;)

Harvey



