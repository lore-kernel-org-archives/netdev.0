From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip monitor neigh: Change 'delete' to 'Deleted'
 to be consistent with ip route
Date: Fri, 16 Oct 2015 16:02:15 -0700
Message-ID: <20151016160215.52b2a307@xeon-e3>
References: <1444934863-12704-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35197 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860AbbJPXCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 19:02:36 -0400
Received: by payp3 with SMTP id p3so1664061pay.2
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 16:02:35 -0700 (PDT)
In-Reply-To: <1444934863-12704-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Oct 2015 11:47:43 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> It helps to grep for one string "Deleted" when monitoring all events.
> 
> Fixes: 6ea3ebafe077 ("iproute2: inform user when a neighbor is removed")
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
> I am not sure if it is too late for this change. But, sending this patch 
> out because it only affects ip monitor output
> 

Sure applied.
