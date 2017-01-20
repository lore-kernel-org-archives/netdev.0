From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv2 iproute2 net-next 1/5] iplink: bridge: add support for
 IFLA_BR_FDB_FLUSH
Date: Fri, 20 Jan 2017 10:34:52 -0800
Message-ID: <20170120103452.26314196@xeon-e3>
References: <1484719971-21693-1-git-send-email-liuhangbin@gmail.com>
        <1484719971-21693-2-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:34189 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752772AbdATSfA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 13:35:00 -0500
Received: by mail-pg0-f44.google.com with SMTP id 14so25504084pgg.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 10:34:59 -0800 (PST)
In-Reply-To: <1484719971-21693-2-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Jan 2017 14:12:47 +0800
Hangbin Liu <liuhangbin@gmail.com> wrote:

> This patch implements support for the IFLA_BR_FDB_FLUSH attribute
> in iproute2 so it can flush bridge fdb dynamic entries.
> 
> Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  ip/iplink_bridge.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 

Applied all of these to net-next, please update man pages.
