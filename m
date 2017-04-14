From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next 2/3] iproute: add support for SR-IPv6
 lwtunnel encapsulation
Date: Fri, 14 Apr 2017 15:46:01 -0700
Message-ID: <20170414154601.6cf5b923@xeon-e3>
References: <20170414123623.28190-1-david.lebrun@uclouvain.be>
        <20170414123623.28190-3-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34379 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752855AbdDNWqE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 18:46:04 -0400
Received: by mail-pf0-f170.google.com with SMTP id c198so45214592pfc.1
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 15:46:03 -0700 (PDT)
In-Reply-To: <20170414123623.28190-3-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Apr 2017 14:36:22 +0200
David Lebrun <david.lebrun@uclouvain.be> wrote:

> +	if (!tb[SEG6_IPTUNNEL_SRH])
> +	return

Bad indentation?
