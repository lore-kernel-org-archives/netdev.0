From: David Miller <davem@davemloft.net>
Subject: Re: [GIT net-next] Open vSwitch
Date: Mon, 04 Nov 2013 16:26:11 -0500 (EST)
Message-ID: <20131104.162611.1615634569631050276.davem@davemloft.net>
References: <1383378230-59624-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54494 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220Ab3KDV0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 16:26:15 -0500
In-Reply-To: <1383378230-59624-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Sat,  2 Nov 2013 00:43:39 -0700

> A set of updates for net-next/3.13. Major changes are:
>  * Restructure flow handling code to be more logically organized and
>    easier to read.
>  * Rehashing of the flow table is moved from a workqueue to flow
>    installation time. Before, heavy load could block the workqueue for
>    excessive periods of time.
>  * Additional debugging information is provided to help diagnose megaflows.
>  * It's now possible to match on TCP flags.

Looks good, pulled, thanks Jesse.
