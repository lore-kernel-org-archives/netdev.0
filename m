From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netback: fix possible format string flaw
Date: Thu, 12 Sep 2013 17:20:20 -0400 (EDT)
Message-ID: <20130912.172020.1121260191605626292.davem@davemloft.net>
References: <20130911043911.GA17237@www.outflux.net>
	<1378883893.3057.60.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: keescook@chromium.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org
To: Ian.Campbell@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378883893.3057.60.camel@dagon.hellion.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Wed, 11 Sep 2013 08:18:13 +0100

> On Tue, 2013-09-10 at 21:39 -0700, Kees Cook wrote:
>> This makes sure a format string cannot accidentally leak into the
>> kthread_run() call.
>> 
>> Signed-off-by: Kees Cook <keescook@chromium.org>
> 
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Applied and queued up for -stable, thanks.
