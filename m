From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [[PATCH iproute2/net-next v2] 1/4] tc: flower: remove
 references to eth_type in manpage
Date: Fri, 2 Dec 2016 15:05:28 -0800
Message-ID: <20161202150528.5fcba382@xeon-e3>
References: <1480668321-20875-1-git-send-email-simon.horman@netronome.com>
        <1480668321-20875-2-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Paul Blakey <paulb@mellanox.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:34530 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755255AbcLBXFb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 18:05:31 -0500
Received: by mail-pg0-f54.google.com with SMTP id x23so112233848pgx.1
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 15:05:31 -0800 (PST)
In-Reply-To: <1480668321-20875-2-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  2 Dec 2016 09:45:18 +0100
Simon Horman <simon.horman@netronome.com> wrote:

> Remove references to eth_type and ether_type (spelling error) in
> the tc flower manpage.
> 
> Also correct formatting of boldface text with whitespace.
> 
> Cc: Paul Blakey <paulb@mellanox.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Applied this one. Later ones still need rebase.
