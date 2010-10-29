From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH 05/15] dec netdev: relocate DIGITAL based drivers to
 legacy
Date: Fri, 29 Oct 2010 06:50:17 +0100 (BST)
Message-ID: <alpine.LFD.2.00.1010290647270.25426@eddie.linux-mips.org>
References: <alpine.LFD.2.00.1010290516110.25426@eddie.linux-mips.org>        <20101028.212939.189691515.davem@davemloft.net>        <alpine.LFD.2.00.1010290545270.25426@eddie.linux-mips.org> <20101028.224703.112589527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:57916 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484Ab0J2FuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 01:50:19 -0400
Received: from localhost.localdomain ([127.0.0.1]:47355 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S1491016Ab0J2FuR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 07:50:17 +0200
In-Reply-To: <20101028.224703.112589527.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Oct 2010, David Miller wrote:

> This patch series started with a "0/15" introduction posting which
> explains the intention and reasoning.

 Well, I didn't reach it (ENOBREAKFAST that has been fixed since ;) ), but 
I sort of guessed it anyway and didn't like the arbitrary nature of 
assigning drivers to legacy/.

> It might be easier for you to read it instead of asking me to repeat
> it's contents :-)

 See my proposal that crossed with your e-mail.  I think it fits the 
purpose very well. :)

  Maciej
