From: jamal <hadi@cyberus.ca>
Subject: Re: [RESEND][PATCH] [NET_SCHED]make qdisc_restart more readable
Date: Thu, 24 May 2007 21:52:14 -0400
Message-ID: <1180057935.4069.5.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902E7C23A@orsmsx414.amr.corp.intel.com>
	 <4655B9C2.4050200@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>, xma@us.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:37688 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbXEYBwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 21:52:20 -0400
Received: by wx-out-0506.google.com with SMTP id t15so486154wxc
        for <netdev@vger.kernel.org>; Thu, 24 May 2007 18:52:19 -0700 (PDT)
In-Reply-To: <4655B9C2.4050200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-24-05 at 18:13 +0200, Patrick McHardy wrote:
> Waskiewicz Jr, Peter P wrote:

> > 
> > One tree, multiple branches, very quick to move between them, low
> > overhead.  If this works for you, also look at stacked GIT (stg) for
> > pushing and popping patches from your tree - very handy.
> 
> 
> I have also found that stgit is a huge time saver, especially for
> making changes to patches or when dealing with many patches with
> interdependencies.

I have had bad experiences with stgit about a year ago - used to mix up
lines between different patches; it may be better now. I think i will
switch to multibranches for now with cogito; wont solve my problem
totaly - but is certainly an improvement over my current process.
I will try stgit at some later point.
Thanks everyone.

cheers,
jamal

