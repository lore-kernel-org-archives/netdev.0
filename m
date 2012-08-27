From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: bridge: remove replace and change options
Date: Mon, 27 Aug 2012 11:46:22 -0700
Message-ID: <20120827114622.419a1b0e@s6510.linuxnetplumber.net>
References: <20120827175231.8706.69184.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60159 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753873Ab2H0SqY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2012 14:46:24 -0400
In-Reply-To: <20120827175231.8706.69184.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Aug 2012 10:52:31 -0700
John Fastabend <john.r.fastabend@intel.com> wrote:

> Replace and change are not supported by bridge netlink so remove it
> from bridge tool options.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 
>  bridge/fdb.c |    7 +------
>  1 files changed, 1 insertions(+), 6 deletions(-)

Applied locally (will get pushed up later).
