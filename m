From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 04:12:59 -0800
Message-ID: <20071113041259.79c9a8c5.akpm@linux-foundation.org>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
	<20071113.033946.114918709.davem@davemloft.net>
	<20071113034916.2556edd7.akpm@linux-foundation.org>
	<20071113.035824.40509981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: protasnb@gmail.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
        linux-pcmcia@lists.infradead.org, linux-input@atrey.karlin.mff.cuni.cz,
        bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <20071113.035824.40509981.davem@davemloft.net>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

On Tue, 13 Nov 2007 03:58:24 -0800 (PST) David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Tue, 13 Nov 2007 03:49:16 -0800
> 
> > Do you believe that our response to bug reports is adequate?
> 
> Do you feel that making us feel and look like shit helps?
> 

That doesn't answer my question.

See, first we need to work out whether we have a problem.  If we do this,
then we can then have a think about what to do about it.

I tried to convince the 2006 KS attendees that we have a problem and I
resoundingly failed.  People seemed to think that we're doing OK.

But it appears that data such as this contradicts that belief.


This is not a minor matter.  If the kernel _is_ slowly deteriorating then
this won't become readily apparent until it has been happening for a number
of years.  By that stage there will be so much work to do to get us back to
an acceptable level that it will take a huge effort.  And it will take a
long time after that for the kerel to get its reputation back.

So it is important that we catch deterioration *early* if it is happening.
