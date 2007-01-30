From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: revert IRQ dance on suspend/resume
Date: Mon, 29 Jan 2007 16:41:15 -0800
Message-ID: <20070129164115.54bda164@freekitty>
References: <Pine.LNX.4.64.0701241847360.25027@woody.linux-foundation.org>
	<1169931333.17469.125.camel@localhost.localdomain>
	<20070129113159.7ad22e4c@freekitty>
	<1170101430.29240.34.camel@localhost.localdomain>
	<20070129133849.1b523226@freekitty>
	<1170109401.29240.49.camel@localhost.localdomain>
	<Pine.LNX.4.64.0701291431320.3611@woody.linux-foundation.org>
	<20070129144055.151cfe52@freekitty>
	<Pine.LNX.4.64.0701291501180.3611@woody.linux-foundation.org>
	<20070129154518.40b0b3d3@freekitty>
	<Pine.LNX.4.64.0701291609180.3611@woody.linux-foundation.org>
	<20070129161626.33277eb1@freekitty>
	<Pine.LNX.4.64.0701291623360.3611@woody.linux-foundation.org>
	<20070129163807.49739750@freekitty>
	<Pine.LNX.4.64.0701291642460.3611@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:35469 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965368AbXA3Anq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 19:43:46 -0500
In-Reply-To: <Pine.LNX.4.64.0701291642460.3611@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 Jan 2007 16:43:04 -0800 (PST)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Mon, 29 Jan 2007, Stephen Hemminger wrote:
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@sony-laptop.(none)>
> 
> Mind if I fix your sign-off? ;)
> 
> 		Linus

Sorry, that was the test machine...


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
