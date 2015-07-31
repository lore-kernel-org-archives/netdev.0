From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: expose COLLECT_METADATA flag to user
 space
Date: Fri, 31 Jul 2015 15:24:15 -0700 (PDT)
Message-ID: <20150731.152415.433150917985876428.davem@davemloft.net>
References: <1438312222-7130-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, tgraf@suug.ch, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51541 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753642AbbGaWYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 18:24:16 -0400
In-Reply-To: <1438312222-7130-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Thu, 30 Jul 2015 20:10:22 -0700

> Two vxlan driver flags FLOWBASED and COLLECT_METADATA need to be set to
> make use of its new flow mode. The former already exposed. Expose the latter.
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied.
