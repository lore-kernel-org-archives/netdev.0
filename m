From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] net: mpls: Add support for netconf
Date: Mon, 20 Feb 2017 14:08:11 +0100
Message-ID: <f45b4787-3eb3-013a-5f86-14b4b388122e@6wind.com>
References: <1487381793-12234-1-git-send-email-dsa@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
        ebiederm@xmission.com
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f179.google.com ([209.85.128.179]:34261 "EHLO
        mail-wr0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752888AbdBTOKT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 09:10:19 -0500
Received: by mail-wr0-f179.google.com with SMTP id z61so64698082wrc.1
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 06:10:19 -0800 (PST)
In-Reply-To: <1487381793-12234-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/02/2017 à 02:36, David Ahern a écrit :
> Add netconf support to MPLS. Allows userpsace to learn and be notified
> of changes to 'input' enable setting per interface.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
