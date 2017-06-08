From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute] tc: flower: add support for matching on ip tos
 and ttl
Date: Thu, 8 Jun 2017 11:01:10 -0700
Message-ID: <20170608110110.0271dcf0@xeon-e3>
References: <1496837874-9284-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35091 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750822AbdFHSBU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 14:01:20 -0400
Received: by mail-pf0-f170.google.com with SMTP id l89so19702266pfi.2
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 11:01:20 -0700 (PDT)
In-Reply-To: <1496837874-9284-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  7 Jun 2017 15:17:54 +0300
Or Gerlitz <ogerlitz@mellanox.com> wrote:

> Allow users to set flower classifier filter rules which
> include matches for ip tos and ttl.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>

Applied to net-next
