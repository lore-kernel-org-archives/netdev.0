From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2 iproute2 net-next 2/2] iproute: Add support for MPLS
 LWT ttl attribute
Date: Tue, 11 Apr 2017 16:37:17 -0600
Message-ID: <452878bb-36e4-e336-2182-8aa4dfd24c53@cumulusnetworks.com>
References: <1491834972-26668-1-git-send-email-rshearma@brocade.com>
 <1491899841-1361-1-git-send-email-rshearma@brocade.com>
 <1491899841-1361-3-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org
To: Robert Shearman <rshearma@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36692 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752429AbdDKWhU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 18:37:20 -0400
Received: by mail-pf0-f170.google.com with SMTP id o126so4711323pfb.3
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 15:37:20 -0700 (PDT)
In-Reply-To: <1491899841-1361-3-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/11/17 2:37 AM, Robert Shearman wrote:
> Add support for setting and displaying the ttl attribute
> for MPLS IP lighweight tunnels.
> 
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  ip/iproute_lwtunnel.c  | 31 +++++++++++++++++++++++++++++--
>  man/man8/ip-route.8.in |  9 ++++++++-
>  2 files changed, 37 insertions(+), 3 deletions(-)
> 

Acked-by: David Ahern <dsa@cumulusnetworks.com>
