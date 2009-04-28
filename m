From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] poll: Avoid extra wakeups in select/poll
Date: Tue, 28 Apr 2009 16:49:36 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904281629090.15947@qirst.com>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com> <49F3308B.1030507@cosmosbay.com> <20090426.020411.157511269.davem@davemloft.net> <49F43B8F.2050907@cosmosbay.com> <87ab60rh8t.fsf@basil.nowhere.org> <49F71B63.8010503@cosmosbay.com>
 <alpine.DEB.1.10.0904281501300.13862@qirst.com> <49F76174.6060009@cosmosbay.com> <alpine.DEB.1.10.0904281612560.13862@qirst.com> <49F767FD.2040205@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux kernel <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, haoki@redhat.com, mchan@broadcom.com,
	davidel@xmailserver.org, Ingo Molnar <mingo@elte.hu>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:48158 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755970AbZD1U64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 16:58:56 -0400
In-Reply-To: <49F767FD.2040205@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Apr 2009, Eric Dumazet wrote:

> The one that did improved your udpping 'bench' :)
>
> http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=bf368e4e70cd4e0f880923c44e95a4273d725ab4

Well yes that is git2p1. The measurements that we took showed not much of
an effect as you see.






