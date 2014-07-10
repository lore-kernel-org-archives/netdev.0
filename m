From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net v2 3/7] net: cpmac: dynamic debug fixes
Date: Thu, 10 Jul 2014 03:17:47 -0700
Message-ID: <1404987467.8839.28.camel@joe-AO725>
References: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>
	 <1404970545-26508-4-git-send-email-varkabhadram@gmail.com>
	 <1404981109.8839.6.camel@joe-AO725> <53BE52B7.40107@gmail.com>
	 <1404983014.8839.8.camel@joe-AO725> <53BE5E6B.1070209@gmail.com>
	 <1404987041.8839.25.camel@joe-AO725> <53BE66CE.9020900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	linux@rainbow-software.org, balbi@ti.com, george.cherian@ti.com,
	davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0050.hostedemail.com ([216.40.44.50]:39769 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751285AbaGJKRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 06:17:50 -0400
In-Reply-To: <53BE66CE.9020900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-10 at 15:41 +0530, Varka Bhadram wrote:
> On 07/10/2014 03:40 PM, Joe Perches wrote:
> > On Thu, 2014-07-10 at 15:05 +0530, Varka Bhadram wrote:
> >> I will submit the patch for this.
> > You'll have to buffer the line locally because
> > there's no simple way to use dynamic debug with
> > line continuations.
> >
> >
> >
> I submitted the patch with subject: net: cpmac: fix in debug messages
> 
> Please see it.

I think you should buffer the lines locally.

btw; It seems what you submitted is a partial revert and
so it should be described as such in the patch description.
