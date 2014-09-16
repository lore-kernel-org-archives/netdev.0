From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v7 0/4] Refactor vxlan and l2tp to use common UDP
 tunnel APIs
Date: Tue, 16 Sep 2014 14:57:02 -0400 (EDT)
Message-ID: <20140916.145702.756160350466154098.davem@davemloft.net>
References: <1410777267-28237-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: azhou@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57027 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754612AbaIPS5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 14:57:04 -0400
In-Reply-To: <1410777267-28237-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>
Date: Mon, 15 Sep 2014 03:34:24 -0700

> Andy Zhou (4):
>   udp_tunnel: Seperate ipv6 functions into its own file.
>   udp-tunnel: Expand UDP tunnel APIs
>   vxlan: Refactor vxlan driver to make use of the common UDP tunnel
>     functions.
>   l2tp: Refactor l2tp core driver to make use of the common UDP tunnel
>     functions

Empty commit log messages like this, especially for the most important
posting (this one) where you are supposed to give a high level
description of what you are doing, why, and listing any pertinent
design decisions you had to make in your implementation.

Please respin this and give full, complete, commit log messages.
