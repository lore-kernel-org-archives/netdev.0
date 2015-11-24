From: Jarod Wilson <jarod@redhat.com>
Subject: Re: severe regression in alx ethernet driver
Date: Tue, 24 Nov 2015 11:07:39 -0500
Message-ID: <20151124160739.GG38006@redhat.com>
References: <CAKM02HMP3WsRYTsm7UVR4tD1jMO5dHrDn6TXg9ARHo-Wqyq2oQ@mail.gmail.com>
 <CAKM02HMMu_FVwSR7OpeyKQ=AUiCqwsjKgOCJJppJJG=tqz0Nog@mail.gmail.com>
 <20151123.111530.2081520486357118720.davem@davemloft.net>
 <20151123.111610.2054291192576855643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ldap.tester@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151123.111610.2054291192576855643.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 23, 2015 at 11:16:10AM -0500, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 23 Nov 2015 11:15:30 -0500 (EST)
> 
> > From: Ldap Tester <ldap.tester@gmail.com>
> > Date: Mon, 23 Nov 2015 11:00:08 -0300
> > 
> >> https://bugzilla.kernel.org/show_bug.cgi?id=70761
> > 
> > Patches sitting in a bugzilla entry will simply rot.
> > 
> > For upstream inclusion someone must formally submit them to the netdev
> > mailing list, with proper commit message, signoffs, etc. and then the
> > patch must be fully reviewed by the community.
> > 
> > Only then will it be applied and make it upstream.
> 
> And amusingly, the final comment in that bugzilla is someone asking
> the patch author to do exactly this.

They do at least have a signed-off-by in the patches attached to the bug,
so I'm working on touching up the descriptions and formatting, regression
testing them on my laptop that has an alx-driven E2200 in it (which isn't
affected by this bug), and then I can ship them up for proper review.

-- 
Jarod Wilson
jarod@redhat.com
