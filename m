From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: net_dropmon usage documentation/examples?
Date: Sat, 6 Apr 2013 08:38:56 -0400
Message-ID: <20130406123856.GA11355@hmsreliant.think-freely.org>
References: <20130405193855.GA27775@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-man@vger.kernel.org
To: Eric Wong <normalperson@yhbt.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55464 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422829Ab3DFMjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Apr 2013 08:39:07 -0400
Content-Disposition: inline
In-Reply-To: <20130405193855.GA27775@dcvr.yhbt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 05, 2013 at 07:38:55PM +0000, Eric Wong wrote:
> Hi Neil, I'm wondering if you have or know of any public
> documentation/examples for using net_dropmon.
> 
> If not, I'll figure it out on my own at some point.
> 
> Thanks in advance!
> 
> (Not a very high priority project for me, my network connectivity
>  problems are sadly _very_ obvious at the moment :x)
> 


I don't think there are any particular examples at the moment, but if you
download the dropwatch utility, it uses the dropmon protocol to detect frame
loss in the stack, and its use is pretty self explanitory, as is the perf script
that uses the same tracepoints as the dropmon protocol.


https://fedorahosted.org/dropwatch/

Regards
Neil
