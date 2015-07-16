From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next]r8169: set bits on Register Interrupt status
 on limit
Date: Thu, 16 Jul 2015 10:07:30 -0700
Message-ID: <55A7E4D2.3020706@gmail.com>
References: <1437041934-2587-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Corcodel Marian <corcodel.marian@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35027 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753081AbbGPRJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 13:09:23 -0400
Received: by pactm7 with SMTP id tm7so46092574pac.2
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 10:09:23 -0700 (PDT)
In-Reply-To: <1437041934-2587-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/07/15 03:18, Corcodel Marian wrote:
> 
>  Set bits on register Interrupt status on limits by
> configuration(critical).
>  On chips not alls bits is in use and some is reserved this patch solve this issue.
> 
>  Committer: Corcodel Marian <asu@192-168-0-3.rdsnet.ro>
>  Changes to be committed:
> 	modified:   drivers/net/ethernet/realtek/r8169.c

Unfortunately, this still does not look like a proper patch submission,
please take the time to read through Documentation/SubmittingPatches,
and also browse the netdev mailing-list for examples on what other
patches submission look like, e.g:
http://marc.info/?l=linux-netdev&m=143701078222680&w=2

If you use git format-patch and git send-email, things are made largely
easier than trying to manually do this.

> 
> Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 


-- 
Florian
