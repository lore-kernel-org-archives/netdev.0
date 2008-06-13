From: David Brownell <david-b@pacbell.net>
Subject: Re: [RESEND #3/patch 2.6.26-rc6] net/enc28j60: low power mode
Date: Fri, 13 Jun 2008 11:21:21 -0700
Message-ID: <200806131121.21346.david-b@pacbell.net>
References: <200806122138.06674.david-b@pacbell.net> <485240A8.5070802@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Claudio Lanconelli <lanconelli.claudio@eptar.com>,
	lkml <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp115.sbc.mail.sp1.yahoo.com ([69.147.64.88]:27366 "HELO
	smtp115.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751091AbYFMSVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 14:21:23 -0400
In-Reply-To: <485240A8.5070802@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 13 June 2008, Jeff Garzik wrote:
> I've put these two into my queue, so they are definitely in process now.

Thanks..


> For netdev patches it helps to CC me, since not every patch sent solely 
> to netdev@ is a to-be-applied patch, and might be missed -- or quite 
> often, assumed to be a patch that warrants discussion.

Ah.  I was more used to the convention that all patches should go to
the relevant mailing list (or LKML), and were assumed to be ready to
merge unless they were flagged as "RFC" or the relevant maintainer(s)
issued a NAK or other negative feedback.  When there was an ack or
signoff from the driver maintainer, it was ready to go.

- Dave

