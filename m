From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] xfrm: Update documentation
Date: Mon, 11 Jul 2011 10:19:54 -0700
Message-ID: <20110711101954.1cce91a2@nehalam.ftrdhcpuser.net>
References: <201106120405.p5C44N7I010008@outgoing.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48118 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758147Ab1GKRTy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 13:19:54 -0400
In-Reply-To: <201106120405.p5C44N7I010008@outgoing.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 11 Jun 2011 22:13:30 -0400
David Ward <david.ward@ll.mit.edu> wrote:

> The ip(8) man page and the "ip xfrm [ XFRM-OBJECT ] help" command output
> are updated to include missing options, fix errors, and improve grammar.
> There are no functional changes made.
> 
> The documentation for the ip command has many different meanings for the
> same formatting symbols (which really needs to be fixed). This patch makes
> consistent use of brackets [ ] to indicate optional parameters, pipes | to
> mean "OR", braces { } to group things together, and dashes - instead of
> underscores _ inside of parameter names. The parameters are listed in the
> order in which they are parsed in the source code.
> 
> There are several parameters and options that are still not mentioned or
> need to be described more thoroughly in the "COMMAND SYNTAX" section of
> the ip(8) man page. I would appreciate help from the developers with this.
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

Applied
