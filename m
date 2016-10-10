From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] ipmroute: add support for age dumping
Date: Sun, 9 Oct 2016 19:10:07 -0700
Message-ID: <20161009191007.4f25752e@xeon-e3>
References: <1474451158-15988-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        anuradhak@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:32816 "EHLO
        mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbcJJCSK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 22:18:10 -0400
Received: by mail-pa0-f49.google.com with SMTP id vu5so8224153pab.0
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2016 19:18:10 -0700 (PDT)
In-Reply-To: <1474451158-15988-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Sep 2016 11:45:58 +0200
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> Add support to dump the mroute cache entry age if the show_stats (-s)
> switch is provided.
> Example:
> $ ip -s mroute
> (0.0.0.0, 239.10.10.10)          Iif: eth0       Oifs: eth0
>   0 packets, 0 bytes, Age  245.44
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied to net-next (pending for 4.9)
