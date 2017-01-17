From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next 5/5] iplink: bridge: add support for
 IFLA_BR_MCAST_MLD_VERSION
Date: Tue, 17 Jan 2017 11:35:27 +0100
Message-ID: <bc7b35b5-52f3-378c-b19b-9e6aeef732c7@cumulusnetworks.com>
References: <1484645552-29440-1-git-send-email-liuhangbin@gmail.com>
 <1484645552-29440-6-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:36727 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751386AbdAQKgT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 05:36:19 -0500
Received: by mail-lf0-f50.google.com with SMTP id z134so99997746lff.3
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 02:35:35 -0800 (PST)
In-Reply-To: <1484645552-29440-6-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/01/17 10:32, Hangbin Liu wrote:
> This patch implements support for the IFLA_BR_MCAST_MLD_VERSION
> attribute in iproute2 so it can change the mcast mld version.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  ip/iplink_bridge.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
