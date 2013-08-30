From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] openvswitch: fix sw_flow_key alignment
Date: Fri, 30 Aug 2013 14:42:11 -0400 (EDT)
Message-ID: <20130830.144211.1550393719904034493.davem@davemloft.net>
References: <1377883940-8995-1-git-send-email-azhou@nicira.com>
	<CAEP_g=9y-HeG0vHS2v-dk7eDp=T0denddykDO3TJtk4UJ062Mg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: azhou@nicira.com, dev@openvswitch.org, netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55739 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855Ab3H3SmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 14:42:15 -0400
In-Reply-To: <CAEP_g=9y-HeG0vHS2v-dk7eDp=T0denddykDO3TJtk4UJ062Mg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 30 Aug 2013 11:22:11 -0700

> The suggestion that Geert made was to just drop this entirely and
> rely on the natural alignment from these values.

Indeed, Geert's patch was 1,000 times superior to this one.
