From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/2] Man page fixes
Date: Wed, 21 Dec 2016 16:10:34 -0800
Message-ID: <20161221161034.04d6a2b4@xeon-e3>
References: <1481607232-1342-1-git-send-email-roid@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Roi Dayan <roid@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:36758 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758295AbcLVAKh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 19:10:37 -0500
Received: by mail-pg0-f51.google.com with SMTP id f188so90610546pgc.3
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 16:10:37 -0800 (PST)
In-Reply-To: <1481607232-1342-1-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Dec 2016 07:33:50 +0200
Roi Dayan <roid@mellanox.com> wrote:

> Hi,
> 
> The 2 patches are man page related only.
> First fixes a typo and second adding missing man page to the Makefile.
> 
> Thanks
> 
> Roi Dayan (2):
>   tc: flower: Fix typo in the flower man page
>   tc: tunnel_key: Add tc-tunnel_key man page to Makefile
> 
>  man/man8/Makefile    | 1 +
>  man/man8/tc-flower.8 | 4 ++--
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 

Applied thanks.
