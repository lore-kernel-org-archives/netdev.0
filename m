From: David Miller <davem@davemloft.net>
Subject: Re: [GIT-PULL Request]: SCTP fixes
Date: Sat, 09 Feb 2008 03:45:27 -0800 (PST)
Message-ID: <20080209.034527.261397372.davem@davemloft.net>
References: <1202502441-16789-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59056
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752852AbYBILo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2008 06:44:57 -0500
In-Reply-To: <1202502441-16789-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri,  8 Feb 2008 15:27:21 -0500

> The following changes since commit 3113e88c3cb3c0a22920b621f8e4d1f2ccc07f1e:
>   Stephen Hemminger (1):
>         [PKT_SCHED]: vlan tag match
> 
> are available in the git repository at:
> 
>   vxy@master.kernel.org:/pub/scm/linux/kernel/git/vxy/lksctp-dev.git pending
> 
> Vlad Yasevich (6):
>       [SCTP]: Stop claiming that this is a "reference implementation"
>       [SCTP]: Do not increase rwnd when reading partial notification.
>       [SCTP]: Kill silly inlines in ulpqueue.c
>       [SCTP]: Correctly reap SSNs when processing FORWARD_TSN chunk
>       [SCTP]: Set ports in every address returned by sctp_getladdrs()
>       [SCTP]: Make sure the chunk is off the transmitted list prior to freeing.
> 
> Wei Yongjun (1):
>       [SCTP]: Fix kernel panic while received ASCONF chunk with bad serial number

Pulled and pushed out to net-2.6, thanks Vlad!
