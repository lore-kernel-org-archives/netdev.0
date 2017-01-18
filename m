From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next] iplink: bridge_slave: add support for
 IFLA_BRPORT_FLUSH
Date: Wed, 18 Jan 2017 12:13:11 +0100
Message-ID: <b7fe5cd4-6780-8dd7-309a-c02244db58ad@cumulusnetworks.com>
References: <1484721405-22519-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:36629 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751951AbdARLOz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 06:14:55 -0500
Received: by mail-lf0-f44.google.com with SMTP id z134so8274346lff.3
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 03:13:14 -0800 (PST)
In-Reply-To: <1484721405-22519-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/01/17 07:36, Hangbin Liu wrote:
> This patch implements support for the IFLA_BRPORT_FLUSH attribute
> in iproute2 so it can flush bridge slave's fdb dynamic entries.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  ip/iplink_bridge_slave.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
