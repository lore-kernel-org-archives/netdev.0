From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] ip: bridge_slave: add support for
 per-port group_fwd_mask
Date: Mon, 16 Oct 2017 09:27:14 -0700
Message-ID: <20171016092714.70d09bec@xeon-e3>
References: <1507900373-9911-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:47822 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756164AbdJPQ1S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 12:27:18 -0400
Received: by mail-pf0-f181.google.com with SMTP id z11so16181617pfk.4
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 09:27:18 -0700 (PDT)
In-Reply-To: <1507900373-9911-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Oct 2017 16:12:53 +0300
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> This patch adds the iproute2 support for getting and setting the
> per-port group_fwd_mask. It also tries to resolve the value into a more
> human friendly format by printing the known protocols instead of only
> the raw value.
> The man page is also updated with the new option.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied. Thanks.
