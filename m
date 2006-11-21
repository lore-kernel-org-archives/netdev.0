From: Luca Tettamanti <kronos.it@gmail.com>
Subject: Re: [PATCH 0/4] atl1: Revised Attansic L1 ethernet driver
Date: Tue, 21 Nov 2006 21:25:41 +0100
Message-ID: <20061121202541.GA23036@dreamland.darkstar.lan>
References: <20061119202817.GA29736@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Cliburn <jacliburn@bellsouth.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:60085 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1031400AbWKUUZr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 15:25:47 -0500
Received: by nf-out-0910.google.com with SMTP id o25so285854nfa
        for <netdev@vger.kernel.org>; Tue, 21 Nov 2006 12:25:46 -0800 (PST)
To: Chris Snook <csnook@redhat.com>
Content-Disposition: inline
In-Reply-To: <20061119202817.GA29736@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Snook <csnook@redhat.com> ha scritto:
> Jay Cliburn wrote:
>> Based upon feedback from Stephen Hemminger and Francois Romieu, please
>> consider this resubmitted patchset that provides support for the Attansic 
>> L1 gigabit ethernet adapter.  This patchset is built against 2.6.19-rc6.  
>> The original patchset was submitted 20060927.
[...]
> 
> I've been working on this with Jay since his initial submission.  Thanks 
> to everyone who has provided feedback on the resubmit.  We're currently 
> quite short on actual testers, since the chip only seems to be on Asus 
> M2V motherboards at present.  Please let me and Jay know if you have one 
> of these boards and would like to test and/or have encountered bugs.

Asus P5B-E also has L1 chip. I'll get the board in a few days and I'll
test whatever patch you throw at me ;)

Luca
-- 
Not an editor command: Wq
