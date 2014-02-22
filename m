From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net v2] net: sctp: rework multihoming retransmission path
 selection to rfc4960
Date: Sat, 22 Feb 2014 12:57:47 +0100
Message-ID: <530890BB.3030005@redhat.com>
References: <1392925866-11084-1-git-send-email-dborkman@redhat.com> <20140222.002707.1190648987229222908.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	guijianfeng@cn.fujitsu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58496 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874AbaBVL6E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Feb 2014 06:58:04 -0500
In-Reply-To: <20140222.002707.1190648987229222908.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/22/2014 06:27 AM, David Miller wrote:
> This does not apply cleanly to the current net tree, please
> respin.

Oh, I have seen you've already applied it. I thought it would
have been conflict-free as Matija's patch only touched
net/sctp/sm_sideeffect.c. Anyway, thanks for fixing it up and
sorry for any inconvenience.

Thanks,

Daniel

  [1] https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=4c47af4d5eb2c2f78f886079a3920a7078a6f0a0
