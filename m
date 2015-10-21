From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] openvswitch: Use dev_queue_xmit for vport
 send.
Date: Wed, 21 Oct 2015 13:33:51 +0200
Message-ID: <20151021133351.6888bda8@griffin>
References: <1445407210-3898-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33261 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752552AbbJULdy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 07:33:54 -0400
In-Reply-To: <1445407210-3898-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Oct 2015 23:00:10 -0700, Pravin B Shelar wrote:
> With use of lwtunnel, we can directly call dev_queue_xmit()
> rather than calling netdev vport send operation.
> Following change make tunnel vport code bit cleaner.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Nice.

Acked-by: Jiri Benc <jbenc@redhat.com>

-- 
Jiri Benc
