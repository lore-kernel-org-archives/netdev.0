From: Paul Moore <paul.moore@hp.com>
Subject: Re: Generic Netlink HOW-TO based on Jamal's original doc
Date: Fri, 10 Nov 2006 11:20:10 -0500
Message-ID: <4554A6BA.6040504@hp.com>
References: <45541757.90800@hp.com> <45549F8D.7010902@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:28379 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1946753AbWKJQUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 11:20:12 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <45549F8D.7010902@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Paul Moore wrote:
> 
>>A couple of months ago I promised Jamal and Thomas I would post some comments to
>>Jamal's original genetlink how-to.  However, as I started to work on the
>>document the diff from the original started to get a little ridiculous so
>>instead of posting a patch against Jamal's original how-to I'm just posting the
>>revised document in it's entirety.
>>
>>In the document below I tried to summarize all of the things I learned while
>>developing NetLabel.  Some of it came from Jamal's document, some the kernel
>>code, and some from discussions with Thomas.  Hopefully this document will make
>>it much easier for others to use genetlink in the future.
>>
>>If this text below is acceptable to everyone, should this be added to the
>>Documentation directory?
>>  
> 
> Mind if we put a wikified version on http://linux-net.osdl.org?

That sounds fine to me, although can we hold off for a little bit so I can
collect some more comments?  Is the wiki open to anyone, i.e. can I add the
document directly, or am I better off just letting you do it?

-- 
paul moore
linux security @ hp
