From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] net: bpf_jit: fix BPF_S_ALU_AND_K compilation
Date: Sat, 31 Mar 2012 08:13:27 -0700
Message-ID: <20120331151327.GA25059@kroah.com>
References: <40f4b91c5200771f223966f368095c63.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	stable@vger.kernel.org, linux-kernel@vger.kernel.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:35090 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760114Ab2CaPN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2012 11:13:29 -0400
Received: from compute2.internal (compute2.nyi.mail.srv.osa [10.202.2.42])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 8F2BE20C5D
	for <netdev@vger.kernel.org>; Sat, 31 Mar 2012 11:13:28 -0400 (EDT)
Content-Disposition: inline
In-Reply-To: <40f4b91c5200771f223966f368095c63.squirrel@webmail.greenhost.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 31, 2012 at 08:52:09PM +1100, Indan Zupancic wrote:
> Hello,
> 
> Finally, after much searching I found one little bug.
> 
> [PATCH] net: bpf_jit: fix BPF_S_ALU_AND_K compilation
> 
> Small typo resulted in bad code generation for certain
> values of K for the BPF_S_ALU_AND_K instruction.
> 
> Signed-off-by: Indan Zupancic <indan@nul.nu>
> ---
> 

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>
