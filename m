From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc: flower: Fix parsing ip address
Date: Thu, 23 Feb 2017 09:01:29 -0800
Message-ID: <20170223090129.2da39424@xeon-e3>
References: <1487772301-22303-1-git-send-email-roid@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Shahar Klein <shahark@mellanox.com>,
        Mark Bloch <markb@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Roi Dayan <roid@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36583 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751722AbdBWRJv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 12:09:51 -0500
Received: by mail-pg0-f50.google.com with SMTP id s67so17240475pgb.3
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 09:09:51 -0800 (PST)
In-Reply-To: <1487772301-22303-1-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Feb 2017 16:05:01 +0200
Roi Dayan <roid@mellanox.com> wrote:

> Fix order of arguments when passed to __flower_parse_ip_addr.
> 
> Fixes: ("f888f4e20534 tc: flower: Support matching ARP")
> Signed-off-by: Roi Dayan <roid@mellanox.com>
> Reviewed-by: Paul Blakey <paulb@mellanox.com>

Applied
