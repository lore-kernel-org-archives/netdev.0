From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] rename RTNH_F_EXTERNAL to RTNH_F_OFFLOAD
Date: Thu, 21 May 2015 15:16:18 -0700
Message-ID: <20150521151618.5fb0d6a7@urahara>
References: <1431577061-12517-1-git-send-email-roopa@cumulusnetworks.com>
	<20150514.224554.1382655632305683978.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, sfeldma@gmail.com, jiri@resnulli.us,
	gospo@cumulusnetworks.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:34389 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756757AbbEUWQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 18:16:15 -0400
Received: by pdbnk13 with SMTP id nk13so1428719pdb.1
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 15:16:15 -0700 (PDT)
In-Reply-To: <20150514.224554.1382655632305683978.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 May 2015 22:45:54 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: roopa@cumulusnetworks.com
> Date: Wed, 13 May 2015 21:17:41 -0700
> 
> > From: Roopa Prabhu <roopa@cumulusnetworks.com>
> > 
> > RTNH_F_EXTERNAL today is printed as "offload" in iproute2 output.
> > 
> > This patch renames the flag to be consistent with what the user sees.
> > 
> > Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Applied, thanks.

I don't see this merge in current net-next tree?
Did it not really happen or was it not pushed?
