From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2 iproute2 net-next 1/2] iproute: Add support for
 ttl-propagation attribute
Date: Tue, 11 Apr 2017 16:37:18 -0600
Message-ID: <1e0ff82b-7ba0-66dd-1130-fb653098d134@cumulusnetworks.com>
References: <1491834972-26668-1-git-send-email-rshearma@brocade.com>
 <1491899841-1361-1-git-send-email-rshearma@brocade.com>
 <1491899841-1361-2-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org
To: Robert Shearman <rshearma@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34648 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752498AbdDKWhV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 18:37:21 -0400
Received: by mail-pf0-f178.google.com with SMTP id c198so4730711pfc.1
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 15:37:20 -0700 (PDT)
In-Reply-To: <1491899841-1361-2-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/11/17 2:37 AM, Robert Shearman wrote:
> Add support for setting and displaying the ttl-propagation attribute
> initially used by MPLS to control propagation of MPLS TTL to IPv4/IPv6
> TTL/hop-limit on popping final label on a per-route basis.
> 
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  ip/iproute.c           | 22 ++++++++++++++++++++++
>  man/man8/ip-route.8.in | 10 +++++++++-
>  2 files changed, 31 insertions(+), 1 deletion(-)
> 

Acked-by: David Ahern <dsa@cumulusnetworks.com>
