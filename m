From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH] lib/utils: improve error messages of get_addr()
 and get_prefix()
Date: Tue, 3 Nov 2015 16:33:01 -0800
Message-ID: <20151103163301.70fafe71@xeon-e3>
References: <1446134738-16732-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:35771 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752748AbbKDAcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 19:32:55 -0500
In-Reply-To: <1446134738-16732-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Oct 2015 17:05:38 +0100
Phil Sutter <phil@nwl.cc> wrote:

> Instead of statically complaining about illegal inet address, use
> get_family() to get the address family right.
> 
> Based on a patch by Hangbin Liu to print "inet6" for AF_INET6 made more
> generic by me.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---

Applied for 4.3 release.
