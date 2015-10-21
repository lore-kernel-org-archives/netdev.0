From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] openvswitch: Use dev_queue_xmit for vport send.
Date: Wed, 21 Oct 2015 10:16:52 +0200
Message-ID: <20151021081652.GA15226@pox.localdomain>
References: <1445407210-3898-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38137 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101AbbJUIQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 04:16:54 -0400
Received: by wicll6 with SMTP id ll6so62458424wic.1
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 01:16:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445407210-3898-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/15 at 11:00pm, Pravin B Shelar wrote:
> With use of lwtunnel, we can directly call dev_queue_xmit()
> rather than calling netdev vport send operation.
> Following change make tunnel vport code bit cleaner.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
