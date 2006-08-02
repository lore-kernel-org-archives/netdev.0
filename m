From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] kernel memory leak fix for af_unix datagram getpeersec
 patch
Date: Wed, 02 Aug 2006 14:11:03 -0700 (PDT)
Message-ID: <20060802.141103.35507776.davem@davemloft.net>
References: <20060802064752.GA21407@jiayuguan.watson.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jmorris@namei.org, sds@tycho.nsa.org, catalin.marinas@gmail.com,
	michal.k.k.piotrowski@gmail.com, czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:35514
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932161AbWHBVKy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 17:10:54 -0400
To: cxzhang@watson.ibm.com
In-Reply-To: <20060802064752.GA21407@jiayuguan.watson.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Catherine you really must begin to remember to add
proper "Signed-off-by: " lines to your patch submissions.

I'll sign off on this bug fix, but in the future I will not
do so for you any more as you've been told at least 3 or 4
times about this.

Thank you.
