From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/7] lwt: Add net to build_state argument
Date: Thu, 15 Sep 2016 10:17:58 -0700
Message-ID: <57DAD7C6.9030207@cumulusnetworks.com>
References: <1473895376-347096-1-git-send-email-tom@herbertland.com> <1473895376-347096-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, tgraf@suug.ch,
        kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35630 "EHLO
        mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751021AbcIORSF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 13:18:05 -0400
Received: by mail-pa0-f50.google.com with SMTP id oz2so13232276pac.2
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 10:18:04 -0700 (PDT)
In-Reply-To: <1473895376-347096-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/14/16, 4:22 PM, Tom Herbert wrote:
> Users of LWT need to know net if they want to have per net operations
> in LWT.
>
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
