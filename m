From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH] net: 3com: typhoon: use new api
 ethtool_{get|set}_link_ksettings
Date: Tue, 01 Nov 2016 16:31:45 -0700
Message-ID: <1478043105.23378.0.camel@dillow-glaptop.roam.corp.google.com>
References: <1478041911-22188-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrix.voodoobox.net ([75.127.97.206]:52678 "EHLO voodoobox.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755000AbcKBAWr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 20:22:47 -0400
In-Reply-To: <1478041911-22188-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-02 at 00:11 +0100, Philippe Reynes wrote:
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

LGTM.

Reviewed-by: David Dillow <dave@thedillows.org>
