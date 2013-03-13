From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 5/6] VXLAN: Use IP Tunnels tunnel ENC encap API
Date: Wed, 13 Mar 2013 15:59:20 -0700
Message-ID: <20130313155920.4fa14f47@nehalam.linuxnetplumber.net>
References: <1363214926-3385-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jesse@nicira.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:49492 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934310Ab3CMW7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 18:59:25 -0400
Received: by mail-pb0-f47.google.com with SMTP id rp2so1486118pbb.34
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 15:59:24 -0700 (PDT)
In-Reply-To: <1363214926-3385-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Mar 2013 15:48:46 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> Use common ecn_encap functions from ip_tunnel module.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Thanks for doing all this.

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
