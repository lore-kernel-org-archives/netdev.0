From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: PATCH WAS( Re: [ANNOUNCE] iproute2 v2.6.25
Date: Thu, 17 Apr 2008 13:46:56 -0700
Message-ID: <20080417134656.761748d4@extreme>
References: <20080417103858.0075236b@extreme>
	<1208464539.15888.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:56963 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752071AbYDQUrB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2008 16:47:01 -0400
In-Reply-To: <1208464539.15888.22.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Apr 2008 16:35:39 -0400
jamal <hadi@cyberus.ca> wrote:

> 
> Quick test:
> My u32 scripts broke. It seems that i need to pass -raw to get same
> output as before; i am sure this will break anyone else depending on old
> output.
> I have introduced a "cooked" mode instead to output new format.
> 

The raw flag already existed and humans are the main users.
