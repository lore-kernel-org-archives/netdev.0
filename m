From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/2] netns: simplify net_ns_init
Date: Thu, 21 May 2009 14:39:51 -0700
Message-ID: <m1bppmqgns.fsf@fess.ebiederm.org>
References: <20090521135846.1fadbe41@nehalam>
	<20090521140042.201351d7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:43053 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083AbZEUVjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 17:39:53 -0400
In-Reply-To: <20090521140042.201351d7@nehalam> (Stephen Hemminger's message of "Thu\, 21 May 2009 14\:00\:42 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> The net_ns_init code can be simplified. No need to save error code
> if it is only going to panic if it is set 4 lines later.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
