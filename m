From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: follow-up: discrepancy with POSIX
Date: Wed, 19 Sep 2007 17:39:04 +0100
Message-ID: <20070919173904.3987ec1b@the-village.bc.nu>
References: <46F13E8B.4050309@redhat.com>
	<20070919.091510.00787167.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: drepper@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761621AbXISQc0@vger.kernel.org>
In-Reply-To: <20070919.091510.00787167.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Sep 2007 09:15:10 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Ulrich Drepper <drepper@redhat.com>
> Date: Wed, 19 Sep 2007 08:21:47 -0700
> 
> > If you think the POSIX spec is wrong (and can point to other
> > implementations doing the same as Linux) let me know and I'll work on
> > getting the spec changed.
> 
> The whole AF_UNSPEC thing I'm almost certain comes from BSD, which has
> behaved that way for centuries.

We got it from the 1003.4g draft socket specification if I remember
rightly. Its entirely plausible that got it from 4BSE.

Alan
