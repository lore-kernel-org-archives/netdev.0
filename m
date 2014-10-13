From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] sfc: efx: add support for skb->xmit_more
Date: Mon, 13 Oct 2014 21:18:32 +0200
Message-ID: <543C2588.6060604@redhat.com>
References: <1413219585-15854-1-git-send-email-dborkman@redhat.com> <543C13AE.80606@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nikolay@redhat.com, netdev@vger.kernel.org,
	Shradha Shah <sshah@solarflare.com>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9770 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751304AbaJMTSn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2014 15:18:43 -0400
In-Reply-To: <543C13AE.80606@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/2014 08:02 PM, Edward Cree wrote:
...
> Until these issues are addressed, I have to NAK this.  Tomorrow I'll try
> to rustle up an rfc patch that handles these issues, unless someone
> beats me to it.

Thanks for your feedback! Yes, please feel free to take this onwards and
integrate/adapt it to your needs for sfc's xmit_more support.

Thanks a lot,
Daniel
