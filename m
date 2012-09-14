From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: bridge: finish removing replace option in man
 pages
Date: Fri, 14 Sep 2012 10:05:20 -0700
Message-ID: <20120914100520.5d711bfd@nehalam.linuxnetplumber.net>
References: <20120914065036.9063.86401.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49092 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757688Ab2INRFv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2012 13:05:51 -0400
In-Reply-To: <20120914065036.9063.86401.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Sep 2012 23:50:36 -0700
John Fastabend <john.r.fastabend@intel.com> wrote:

> This patch finishes removing the replace option from the bridge
> man page which I missed in this commit
> 
> commit 57b9785de32404da3d2ac5483469b7fcc5a9c9e7
> Author: John Fastabend <john.r.fastabend@intel.com>
> Date:   Mon Aug 27 10:52:31 2012 -0700
> 
>     iproute2: bridge: remove replace and change options
> 
> Also add documentation for "{ self | embedded }" already shown on
> the cmd line help msg.
> 

Applied, thanks
