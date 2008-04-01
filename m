From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 0/5] [IPROUTE2] Add overhead parameter for CBQ, TBF and
 police
Date: Tue, 1 Apr 2008 12:23:51 -0700
Message-ID: <20080401122351.752e5ecf@extreme>
References: <1206312248.15884.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:60781 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755072AbYDATX4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2008 15:23:56 -0400
In-Reply-To: <1206312248.15884.26.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Mar 2008 23:44:08 +0100
Jesper Dangaard Brouer <jdb@comx.dk> wrote:

> Hi Stephen
> 
> This can be view as a maintanance patchset for iproute2.  The overhead
> parameter, introduced in kernel 2.6.24, were only implemented for HTB
> in iproute2/tc.
> 
> This patchset adds overhead parameter parsing for the last rate-table
> based schedulers CBQ, TFB and police.
> 
> The changes are ABI (Application Binary Interface) backward compatible
> with older kernels, but will first have effect from kernel 2.6.24.
> 
> 
> See you soon :-)

Appled for 2.6.25 version
