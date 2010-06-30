From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: add per bridge device controls for invoking
 iptables
Date: Wed, 30 Jun 2010 14:24:40 -0700
Message-ID: <20100630142440.68adfdb1@nehalam>
References: <1277729220-11775-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48737 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757226Ab0F3VYn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jun 2010 17:24:43 -0400
In-Reply-To: <1277729220-11775-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Jun 2010 14:47:00 +0200
kaber@trash.net wrote:

> From: Patrick McHardy <kaber@trash.net>
> 
> Support more fine grained control of bridge netfilter iptables invocation
> by adding seperate brnf_call_*tables parameters for each device using the
> sysfs interface. Packets are passed to layer 3 netfilter when either the
> global parameter or the per bridge parameter is enabled.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Looks like a good idea.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

-- 
