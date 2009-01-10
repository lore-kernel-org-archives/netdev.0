From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] nes: fix reversed IP address
Date: Fri, 09 Jan 2009 22:49:06 -0800
Message-ID: <1231570146.5714.26.camel@brick>
References: <adaprivom8o.fsf@cisco.com>  <1231568675.5714.25.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:44361 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbZAJGtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 01:49:08 -0500
Received: by wf-out-1314.google.com with SMTP id 27so10244130wfd.4
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2009 22:49:08 -0800 (PST)
In-Reply-To: <1231568675.5714.25.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-01-09 at 22:24 -0800, Harvey Harrison wrote:
> commit 63779436ab4ad0867bcea53bf853b0004d7b895di (drivers: replace NIPQUAD())
> accidentally replaced two HIPQUAD()s causing IP addresses to be
> printed in reverse order, add two temporary local vars.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---

Sorry missed a git add after catching the other hunks, will get this
right in the morning.

Harvey

