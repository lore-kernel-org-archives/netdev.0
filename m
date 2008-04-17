From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: PATCH WAS( Re: [ANNOUNCE] iproute2 v2.6.25
Date: Thu, 17 Apr 2008 14:08:37 -0700
Message-ID: <20080417140837.1e92b449@extreme>
References: <20080417103858.0075236b@extreme>
	<1208464539.15888.22.camel@localhost>
	<20080417134656.761748d4@extreme>
	<1208465951.15888.33.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:57486 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755699AbYDQVIm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2008 17:08:42 -0400
In-Reply-To: <1208465951.15888.33.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Apr 2008 16:59:11 -0400
jamal <hadi@cyberus.ca> wrote:

> On Thu, 2008-17-04 at 13:46 -0700, Stephen Hemminger wrote:
> 
> > The raw flag already existed and humans are the main users.
> 
> My scripts dont count as humans ;->
> "raw" was not intepreted for the output on u32. Your patch changed the
> semantics when you added what amounts to a cooked mode. 
> I think changing old standing outputs should be treated in the same
> spirit as existing ABIs. Was this ever posted somewhere - I apologize if
> the discussion already happened.
> 
> cheers,
> jamal
> 

By that logic no program output would ever change. 
