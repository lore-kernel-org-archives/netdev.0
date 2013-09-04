From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sctp: probe: allow more advanced ingress
 filtering by mark
Date: Tue, 03 Sep 2013 21:44:45 -0400 (EDT)
Message-ID: <20130903.214445.2061960310257902954.davem@davemloft.net>
References: <1377795289-1914-1-git-send-email-dborkman@redhat.com>
	<20130830113630.GB1142@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53596 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761603Ab3IDBoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 21:44:46 -0400
In-Reply-To: <20130830113630.GB1142@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 30 Aug 2013 07:36:30 -0400

> On Thu, Aug 29, 2013 at 06:54:49PM +0200, Daniel Borkmann wrote:
>> This is a follow-up commit for commit b1dcdc68b1f4 ("net: tcp_probe:
>> allow more advanced ingress filtering by mark") that allows for
>> advanced SCTP probe module filtering based on skb mark (for a more
>> detailed description and advantages using mark, refer to b1dcdc68b1f4).
>> The current option to filter by a given port is still being preserved.
>> 
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
