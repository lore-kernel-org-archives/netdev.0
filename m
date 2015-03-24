From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH iproute2 v2] man ip-netns: Fix syntax in default ns
 process, indent's
Date: Tue, 24 Mar 2015 18:20:29 +0900
Message-ID: <20150324092027.GA17115@vergenet.net>
References: <1426960318-12044-1-git-send-email-vadim4j@gmail.com>
 <20150323011120.GA20755@vergenet.net>
 <20150324082924.GA1276@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ben@decadent.org.uk
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35113 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643AbbCXJUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 05:20:39 -0400
Received: by pdbop1 with SMTP id op1so215619427pdb.2
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 02:20:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150324082924.GA1276@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vadim,

On Tue, Mar 24, 2015 at 10:29:24AM +0200, Vadim Kochan wrote:
> On Mon, Mar 23, 2015 at 10:11:24AM +0900, Simon Horman wrote:
> > On Sat, Mar 21, 2015 at 07:51:58PM +0200, Vadim Kochan wrote:

[snip]

> Hi,
> 
> So may it be like this ?
> 
> 	By default a process inherits its network namespace from the parent.
> 
> or like this ?
> 
> 	By default a process inherits its network namespace from its parent.

The second option seems best to me.
