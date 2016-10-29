From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched actions: use nla_parse_nested()
Date: Sat, 29 Oct 2016 15:01:19 -0400 (EDT)
Message-ID: <20161029.150119.1766801518660220661.davem@davemloft.net>
References: <1477485873-32598-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51824 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751479AbcJ2TBU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 15:01:20 -0400
In-Reply-To: <1477485873-32598-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 26 Oct 2016 14:44:33 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> Use nla_parse_nested instead of open-coding the call to
> nla_parse() with the attribute data/len.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied, thanks.
