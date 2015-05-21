From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] rename RTNH_F_EXTERNAL to RTNH_F_OFFLOAD
Date: Thu, 21 May 2015 16:46:30 -0700
Message-ID: <20150521164630.23fbba18@urahara>
References: <1431577061-12517-1-git-send-email-roopa@cumulusnetworks.com>
	<20150514.224554.1382655632305683978.davem@davemloft.net>
	<20150521151618.5fb0d6a7@urahara>
	<20150521.184010.1674602649748676614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, sfeldma@gmail.com, jiri@resnulli.us,
	gospo@cumulusnetworks.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:33799 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754119AbbEUXq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 19:46:27 -0400
Received: by pdbnk13 with SMTP id nk13so3479088pdb.1
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 16:46:27 -0700 (PDT)
In-Reply-To: <20150521.184010.1674602649748676614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 May 2015 18:40:10 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Thu, 21 May 2015 15:16:18 -0700
> 
> > On Thu, 14 May 2015 22:45:54 -0400 (EDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> >> From: roopa@cumulusnetworks.com
> >> Date: Wed, 13 May 2015 21:17:41 -0700
> >> 
> >> > From: Roopa Prabhu <roopa@cumulusnetworks.com>
> >> > 
> >> > RTNH_F_EXTERNAL today is printed as "offload" in iproute2 output.
> >> > 
> >> > This patch renames the flag to be consistent with what the user sees.
> >> > 
> >> > Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> >> 
> >> Applied, thanks.
> > 
> > I don't see this merge in current net-next tree?
> > Did it not really happen or was it not pushed?
> 
> It went to the 'net' tree and I haven't done a merge in a while.

Ok, that will go to Linus, right.
Trying to coordinate the iproute2 changes related to this.
