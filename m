From: David Miller <davem@davemloft.net>
Subject: Re: [GIT net-next] Open vSwitch
Date: Fri, 23 May 2014 14:46:18 -0400 (EDT)
Message-ID: <20140523.144618.48288319728715940.davem@davemloft.net>
References: <1400576378-2171-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org, netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54518 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbaEWSqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 14:46:20 -0400
In-Reply-To: <1400576378-2171-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue, 20 May 2014 01:59:38 -0700

> A set of OVS changes for net-next/3.16.
> 
> Most of change are related to improving performance of flow setup by
> minimizing critical sections.

Pulled, thanks Pravin.

In the future please make your postings so that they have the current date
and time when you make the postings, not when the commits when into your
tree.

Otherwise it messed up the order in which your changes appear in patchwork
wrt. other submissions.
