From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH v2] stmmac: Add device-tree support
Date: Tue, 13 Mar 2012 12:40:45 +0100
Message-ID: <201203131240.46050.sr@denx.de>
References: <1331623394-14600-1-git-send-email-sr@denx.de> <201203131129.34449.sr@denx.de> <4F5F2B56.2060504@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree-discuss@ozlabs.org" <devicetree-discuss@ozlabs.org>,
	"spear-devel" <spear-devel@list.st.com>,
	Peppe CAVALLARO <peppe.cavallaro@st.com>
To: Viresh Kumar <viresh.kumar@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.182]:11051 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757901Ab2CMLlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 07:41:07 -0400
In-Reply-To: <4F5F2B56.2060504@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 13 March 2012 12:11:18 Viresh Kumar wrote:
> On 3/13/2012 3:59 PM, Stefan Roese wrote:
> > Consistency. pr_err is used in this driver. So I'm sticking to it with
> > this patch as well.
> 
> Hmmm. I don't know, but can you add another patch before this one to move
> those prints.

Sure, I could. But I have to admit that this is currently not top of my 
priority.

Peppe as driver maintainer might have some input here. Is this dev_err vs 
pr_err a show-stopper for this patch?

Thanks,
Stefan
