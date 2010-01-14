From: David Miller <davem@davemloft.net>
Subject: Re: netdev: patchwork.ozlabs.org vs patchwork.kernel.org ?
Date: Wed, 13 Jan 2010 17:41:41 -0800 (PST)
Message-ID: <20100113.174141.169192840.davem@davemloft.net>
References: <3DBBD805E3BA064A87F551C0E8BD36740289748A@MAILSRV.intcomgrp.com>
	<20100113.173253.223656114.davem@davemloft.net>
	<1263433237.1966.37.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755305Ab0ANBld@vger.kernel.org>
In-Reply-To: <1263433237.1966.37.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 13 Jan 2010 17:40:37 -0800

> On Wed, 2010-01-13 at 17:32 -0800, David Miller wrote:
>> Encoding your patches as base64 binary octet stream attachments
>> causes them to get missed by our automated patch tracking system:
>> 
>> 	http://patchwork.ozlabs.org/project/netdev/list/
> 
> What is the reason why netdev doesn't use patchwork.kernel.org?
> 
> It seems odd that it doesn't.  Odd like the arm mailing lists.

ozlabs was the original, and so just like powerpc port that's where we
started using the tool.

I honestly don't care where it's hosted.
