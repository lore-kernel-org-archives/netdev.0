From: Ben Pfaff <blp@nicira.com>
Subject: Re: openvswitch/flow WAS ( Re: [rfc] Merging the Open vSwitch
 datapath
Date: Fri, 15 Oct 2010 09:18:23 -0700
Message-ID: <20101015161823.GA5110@nicira.com>
References: <20100830062755.GA22396@verge.net.au>
 <87k4n8ow1r.fsf@benpfaff.org>
 <1287142292.3642.19.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Jesse Gross <jesse@nicira.com>,
	netdev@vger.kernel.org
To: ovs-team@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from outmail149077.authsmtp.com ([62.13.149.77]:58100 "EHLO
	outmail149077.authsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932115Ab0JOQuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 12:50:05 -0400
Content-Disposition: inline
In-Reply-To: <1287142292.3642.19.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[adding ovs-team]

On Fri, Oct 15, 2010 at 07:31:32AM -0400, jamal wrote:
> 
> Sorry, slightly off topic - and this old (catching up 
> with netdev randomly going backwards)..
> 
> I was curious after seeing the exchange with Eric D. on
> the tunnels and how you have your own tree so i glossed 
> over what your project is doing.
> 
> It seems to me that you reinvented things that exist in 
> Linux already such as bridging, tunnels and what really
> caught my attention: ability to do flows (tc actions).
> It is possible Linux is missing something you wanted or was
> not efficient enough? 
> [For example: I couldnt see anything you needed
> on flow-action management that Linux couldnt do already
> (with already very nice well structured netlink APIs)]
