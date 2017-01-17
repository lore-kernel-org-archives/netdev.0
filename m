From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next 1/5] iplink: bridge: add support for
 IFLA_BR_FDB_FLUSH
Date: Tue, 17 Jan 2017 11:36:05 +0100
Message-ID: <480a1691-de10-9b6b-ad86-17469d5dd226@cumulusnetworks.com>
References: <1484645552-29440-1-git-send-email-liuhangbin@gmail.com>
 <1484645552-29440-2-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:35589 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751762AbdAQKgT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 05:36:19 -0500
Received: by mail-lf0-f48.google.com with SMTP id n124so34722032lfd.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 02:36:08 -0800 (PST)
In-Reply-To: <1484645552-29440-2-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/01/17 10:32, Hangbin Liu wrote:
> This patch implements support for the IFLA_BR_FDB_FLUSH attribute
> in iproute2 so it can flush bridge fdb dynamic entries.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  ip/iplink_bridge.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
