From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: mpls: Update lfib_nlmsg_size to skip deleted
 nexthops
Date: Tue, 28 Mar 2017 16:23:17 -0700
Message-ID: <58DAF065.40709@cumulusnetworks.com>
References: <1490739589-3039-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:34244 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753237AbdC1XXU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:23:20 -0400
Received: by mail-pg0-f43.google.com with SMTP id 21so85935056pgg.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 16:23:19 -0700 (PDT)
In-Reply-To: <1490739589-3039-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/28/17, 3:19 PM, David Ahern wrote:
> A recent commit skips nexthops in a route if the device has been
> deleted. Update lfib_nlmsg_size accordingly.
>
> Reported-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
