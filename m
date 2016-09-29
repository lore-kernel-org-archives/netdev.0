From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netfilter: bridge: clarify bridge/netfilter message
Date: Thu, 29 Sep 2016 04:25:20 +0200
Message-ID: <20160929022520.GH17426@breakpoint.cc>
References: <20160928220528.17478-1-stefan@agner.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, davem@davemloft.net,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, pablo@netfilter.org
To: Stefan Agner <stefan@agner.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:58968 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751268AbcI2CZg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 22:25:36 -0400
Content-Disposition: inline
In-Reply-To: <20160928220528.17478-1-stefan@agner.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Agner <stefan@agner.ch> wrote:
> When using bridge without bridge netfilter enabled the message
> displayed is rather confusing and leads to belive that a deprecated
> feature is in use. Use IS_MODULE to be explicit that the message only
> affects users which use bridge netfilter as module and reword the
> message.

Acked-by: Florian Westphal <fw@strlen.de>
