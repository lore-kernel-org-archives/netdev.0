From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [0/9][2.6] via-rhine patches
Date: Wed, 2 Jun 2004 21:53:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040602195316.GA31791@k3.hellgate.ch>
References: <20040602115703.GA16079@k3.hellgate.ch> <40BE2A90.7020508@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40BE2A90.7020508@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 02 Jun 2004 15:29:20 -0400, Jeff Garzik wrote:
> Question -- are any of these needed for the 2.6.7 Release Candidate?

No. Any significant change in driver behavior would be a bug. Patches
submitted so far are clean-up in preparation for functional changes
to come.

> I prefer to defer these to post-2.6.7 as cleanup patches, since they are 
> not bug fixes.

ACK. Please note, though, that I have another set of patches coming up
which will be quite a bit more intrusive and will need review and wider
testing. I plan to submit in time for 2.6.8-pre, even though some of
it may not make it into 2.6.8.

Roger
