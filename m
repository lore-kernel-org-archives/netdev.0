From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC repost 5/8] datapath: Move last_action() helper to
 datapath.h
Date: Thu, 25 Sep 2014 13:42:06 +0900
Message-ID: <20140925044204.GA25070@vergenet.net>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
 <1411005311-11752-6-git-send-email-simon.horman@netronome.com>
 <20140919140638.GC8257@casper.infradead.org>
 <20140924060013.GB13314@vergenet.net>
 <20140924082015.GC24298@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:46548 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbaIYEmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 00:42:18 -0400
Received: by mail-pd0-f177.google.com with SMTP id v10so8086776pde.22
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 21:42:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140924082015.GC24298@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2014 at 09:20:15AM +0100, Thomas Graf wrote:
> On 09/24/14 at 03:00pm, Simon Horman wrote:
> > On Fri, Sep 19, 2014 at 03:06:38PM +0100, Thomas Graf wrote:
> > > Can we rename & move this to <net/netlink.h> instead?
> > 
> > Sure, how about nla_is_last()?
> 
> Sounds great

Done. I have posted the result as a patch separate to the select group series.
