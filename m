From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: igb transmit queue timed out, rcu_sched_state detected stall
Date: Mon, 15 Aug 2011 19:07:34 +0100
Message-ID: <1313431654.2731.20.camel@bwh-desktop>
References: <CALJvf+qLZyXpxfDR-3aJVn2Qf558SKPc85NpQOosafqxCUC46w@mail.gmail.com>
	 <CALJvf+qGt=GkD2oV8GEz7DWLzpCZGaAE5Gpse8HvPjgpT2Wmxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Peter Neal <doabackflip@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:17134 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934Ab1HOSHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 14:07:39 -0400
In-Reply-To: <CALJvf+qGt=GkD2oV8GEz7DWLzpCZGaAE5Gpse8HvPjgpT2Wmxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-08-15 at 15:33 +0100, Peter Neal wrote:
> I have updated the BIOS, iproute2, e1000e and igb drivers, but am
> still seeing issues, any thoughts?
[...]

This issue doesn't seem network-related.  However it might be related to
this regression that I saw discussed just a few minutes ago:

Bug-Entry     : http://bugzilla.kernel.org/show_bug.cgi?id=40092
Subject       : RCU stall in linux-3.0.0
Submitter     : Philip Armstrong <phil@kantaka.co.uk>
Date          : 2011-07-25 21:44 (21 days old)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

