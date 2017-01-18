From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCHv2 iproute2 net-next 2/5] iplink: bridge: add support for
 IFLA_BR_VLAN_STATS_ENABLED
Date: Wed, 18 Jan 2017 12:11:50 +0100
Message-ID: <7895d5e8-3685-18e0-b280-a331ff8e8cc8@cumulusnetworks.com>
References: <1484719971-21693-1-git-send-email-liuhangbin@gmail.com>
 <1484719971-21693-3-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33087 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754906AbdARLL7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 06:11:59 -0500
Received: by mail-lf0-f47.google.com with SMTP id k86so8293392lfi.0
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 03:11:53 -0800 (PST)
In-Reply-To: <1484719971-21693-3-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/01/17 07:12, Hangbin Liu wrote:
> This patch implements support for the IFLA_BR_VLAN_STATS_ENABLED
> attribute in iproute2 so it can enable/disable vlan stats accounting.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  ip/iplink_bridge.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 

Thanks,
Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
