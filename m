From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] other ircomm_tty fixes
Date: Tue, 05 Mar 2013 23:44:07 -0500 (EST)
Message-ID: <20130305.234407.1723377842328472099.davem@davemloft.net>
References: <1362371063.3221.185.camel@thor.lan>
	<1362499747-4262-1-git-send-email-peter@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, sasha.levin@oracle.com,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org, jslaby@suse.cz,
	linux-kernel@vger.kernel.org
To: peter@hurleysoftware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362499747-4262-1-git-send-email-peter@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Hurley <peter@hurleysoftware.com>
Date: Tue,  5 Mar 2013 11:09:03 -0500

> On Sun, 2013-03-03 at 23:24 -0500, Peter Hurley wrote:
>> In the meantime, while reviewing that code, I noticed there's a handful
>> of serious bugs in that one function that I'll send a patchset for.
> 
> As promised.
> 
> 
> Peter Hurley (4):
>   net/irda: Fix port open counts
>   net/irda: Hold port lock while bumping blocked_open
>   net/irda: Use barrier to set task state
>   net/irda: Raise dtr in non-blocking open

Series looks good, all applied, thanks Peter!
