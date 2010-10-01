From: Elly Jones <ellyjones@google.com>
Subject: Re: [PATCH 0/2] qcusbnet: Cleanups
Date: Fri, 1 Oct 2010 10:42:32 -0400
Message-ID: <20101001144231.GC8632@google.com>
References: <20100928171026.GB6083@google.com> <cover.1285727642.git.joe@perches.com> <20100930.173338.149831717.davem@davemloft.net> <1285893935.10780.11.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	dbrownell@users.sourceforge.net, mjg59@srcf.ucam.org,
	jglasgow@google.com, msb@google.com, olofj@google.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:45408 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756833Ab0JAOmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 10:42:38 -0400
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o91Egafb018073
	for <netdev@vger.kernel.org>; Fri, 1 Oct 2010 07:42:36 -0700
Received: from pzk7 (pzk7.prod.google.com [10.243.19.135])
	by kpbe18.cbf.corp.google.com with ESMTP id o91EgZ8O021386
	for <netdev@vger.kernel.org>; Fri, 1 Oct 2010 07:42:35 -0700
Received: by pzk7 with SMTP id 7so962194pzk.13
        for <netdev@vger.kernel.org>; Fri, 01 Oct 2010 07:42:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1285893935.10780.11.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 30, 2010 at 05:45:35PM -0700, Joe Perches wrote:
> On Thu, 2010-09-30 at 17:33 -0700, David Miller wrote:
> > From: Joe Perches <joe@perches.com>
> > Date: Tue, 28 Sep 2010 19:39:56 -0700
> > > Perhaps some of these cleanups are in order?
> > I don't see this driver in any of my trees, so someone else
> > should be taking this in it seems.
> 
> These cleanups are meant for Elly Jones on top
> of the Qualcomm Gobi 2000 driver she submitted.
> 
> http://patchwork.ozlabs.org/patch/66006/
> 

Wow, thank you! I'll incorporate your fixes, make sure I have clean
checkpatch output, and send a v2.

-- Elly
