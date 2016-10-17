From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] bridge: vlan: remove wrong stats help
Date: Mon, 17 Oct 2016 05:23:21 -0700
Message-ID: <20161017052321.7d129703@xeon-e3>
References: <1476277348-32302-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34651 "EHLO
        mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932588AbcJQMXM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 08:23:12 -0400
Received: by mail-pa0-f51.google.com with SMTP id rz1so63073943pab.1
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 05:23:07 -0700 (PDT)
In-Reply-To: <1476277348-32302-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Oct 2016 15:02:28 +0200
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> When I did the per-vlan stats iproute2 support, I left out a hunk from a
> previous version of the patch that was using a special subcommand "stats".
> Since the latest version uses the -s switch remove the help for the stats
> subcommand.
> 
> Fixes: 7abf5de677e32 ("bridge: vlan: add support to display per-vlan statistics")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> The commit is only in iproute2 net-next branch.
> 
>  bridge/vlan.c | 1 -
>  1 file changed, 1 deletion(-)

Applied thanks.
