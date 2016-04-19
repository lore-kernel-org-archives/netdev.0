From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH 0/2] Minor ss filter fix and review
Date: Tue, 19 Apr 2016 07:57:22 -0700
Message-ID: <20160419075722.5a96bd1f@xeon-e3>
References: <20160329193242.GA28502@orbyte.nwl.cc>
	<1460578025-12224-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Vadim Kochan <vadim4j@gmail.com>, <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:1662 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932106AbcDSO5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 10:57:14 -0400
In-Reply-To: <1460578025-12224-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Apr 2016 22:07:03 +0200
Phil Sutter <phil@nwl.cc> wrote:

> While looking for a solution to the problem described in patch 2/2, I
> discovered the overly complicated assignment in filter_states_set() which
> is simplified in patch 1/2.
> 
> Phil Sutter (2):
>   ss: Drop silly assignment
>   ss: Fix accidental state filter override
> 
>  misc/ss.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 

Applied
