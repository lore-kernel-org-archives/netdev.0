From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH 0/2] ip-neighbour: Add missing nud state
 descriptions
Date: Fri, 4 Mar 2016 15:36:14 -0800
Message-ID: <20160304153614.0cf366b7@xeon-e3>
References: <1a9a42073352495c827050fc81483817@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:35014 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759633AbcCDXgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 18:36:05 -0500
In-Reply-To: <1a9a42073352495c827050fc81483817@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Mar 2016 19:07:19 +0000
Phil Sutter <phil@nwl.cc> wrote:

> The following aims at documenting all nud states 'ip neigh' supports, not just
> the most common ones. This includes describing them in the relevant man page as
> well as extending 'ip neigh help' output.
> 
> Phil Sutter (2):
>   man: ip-neighbour.8: Document all known nud states
>   ipneigh: List all nud states in help output
> 
>  ip/ipneigh.c            |  9 +++++----
>  man/man8/ip-neighbour.8 | 22 +++++++++++++++++++++-
>  2 files changed, 26 insertions(+), 5 deletions(-)
> 

Applied
