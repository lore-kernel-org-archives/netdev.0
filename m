From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: CODEL et al.
Date: Tue, 22 May 2012 14:28:00 -0700
Message-ID: <20120522142800.0fcd378e@nehalam.linuxnetplumber.net>
References: <20120522.152424.2220976457698189461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42797 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751625Ab2EVV2E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2012 17:28:04 -0400
In-Reply-To: <20120522.152424.2220976457698189461.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 May 2012 15:24:24 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> 
> Stephen, could you please provide a tree (if you don't already)
> that has all of the CODEL et al. iproute2 feature patches applied
> and mark the patchwork patches as applied??
> 
> Otherwise people have to do unreasonable things to test the new
> features that are in Linus's tree already.
> 
> Thanks.

Since codel is now merged, just finished merging all the outstanding
iproute2 patches for 3.5.
