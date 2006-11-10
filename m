From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Generic Netlink HOW-TO based on Jamal's original doc
Date: Fri, 10 Nov 2006 07:49:33 -0800
Message-ID: <45549F8D.7010902@osdl.org>
References: <45541757.90800@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:63720 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1946712AbWKJPtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 10:49:46 -0500
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <45541757.90800@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Moore wrote:
> A couple of months ago I promised Jamal and Thomas I would post some comments to
> Jamal's original genetlink how-to.  However, as I started to work on the
> document the diff from the original started to get a little ridiculous so
> instead of posting a patch against Jamal's original how-to I'm just posting the
> revised document in it's entirety.
>
> In the document below I tried to summarize all of the things I learned while
> developing NetLabel.  Some of it came from Jamal's document, some the kernel
> code, and some from discussions with Thomas.  Hopefully this document will make
> it much easier for others to use genetlink in the future.
>
> If this text below is acceptable to everyone, should this be added to the
> Documentation directory?
>   
Mind if we put a wikified version on http://linux-net.osdl.org?
