From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [5/5] e1000e: Avoid receiver overrun interrupt bursts
Date: Tue, 24 Oct 2017 13:20:27 -0400
Message-ID: <20171024172027.onfcusdcicxqnfjp@csclub.uwaterloo.ca>
References: <20170721183627.13373-5-bpoirier@suse.com>
 <DDD41C67-CDF2-4443-9F49-0DC5489D9243@redfish-solutions.com>
 <20170919194102.h2nu72evbqhpu765@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Philip Prindeville <philipp_subx@redfish-solutions.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        linux-kernel@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:42941 "EHLO
        caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751378AbdJXR0E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 13:26:04 -0400
Content-Disposition: inline
In-Reply-To: <20170919194102.h2nu72evbqhpu765@f1.synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 09:41:02PM +0200, Benjamin Poirier wrote:
> On 2017/09/19 12:38, Philip Prindeville wrote:
> > Hi.
> > 
> > We’ve been running this patchset (all 5) for about as long as they’ve been under review… about 2 months.  And in a burn-in lab with heavy traffic.
> > 
> > We’ve not seen a single link-flap in hundreds of ours of saturated traffic.
> > 
> > Would love to see some resolution soon on this as we don’t want to ship a release with unsanctioned patches.
> > 
> > Is there an estimate on when that might be?
> 
> The patches have been added to Jeff Kirsher's next-queue tree. I guess
> they will be submitted for v4.15 which might be released in early
> 2018...
> http://phb-crystal-ball.org/

And then they will be submitted to linux-stable so this long standing
regression can be fixed, right?

-- 
Len Sorensen
