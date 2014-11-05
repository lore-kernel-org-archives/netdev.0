From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net v4] ipv6: mld: fix add_grhead skb_over_panic for devs
 with large MTUs
Date: Wed, 05 Nov 2014 22:31:21 +0100
Message-ID: <545A9729.8020308@redhat.com>
References: <1415215658-10054-1-git-send-email-dborkman@redhat.com> <1415220449.13896.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, lw1a2.jing@gmail.com, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David L Stevens <david.stevens@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44882 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936AbaKEVbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 16:31:36 -0500
In-Reply-To: <1415220449.13896.15.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2014 09:47 PM, Eric Dumazet wrote:
...
> Thanks for your patience ;)

No problem, thanks for the feedback, Eric!
