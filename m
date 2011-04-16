From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Steps to integrate new 40G Network driver to the kernel tree
Date: Sat, 16 Apr 2011 01:57:00 +0100
Message-ID: <1302915420.5282.783.camel@localhost>
References: <4DA8D9F6.2070908@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Joyce Yu - System Software <joyce.yu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12199 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755579Ab1DPA5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 20:57:03 -0400
In-Reply-To: <4DA8D9F6.2070908@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-15 at 16:51 -0700, Joyce Yu - System Software wrote:
> Hello,
> 
> We have a new 40G network Linux driver. What are the steps to integrate  
> it to the kernel tree?

Make sure it works as an addition to David Miller's net-2.6 git tree.
Send patches here for review, in <100K chunks (that's the limit for this
list).  Update it based on review feedback, and repeat as necessary.

Documentation/SubmittingPatches has general advice on patches.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

