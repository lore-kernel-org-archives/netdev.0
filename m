From: Rene Herman <rene.herman@keyaccess.nl>
Subject: Re: size of git repository (was Re: [BUG] New Kernel Bugs)
Date: Sun, 18 Nov 2007 13:58:18 +0100
Message-ID: <474036EA.9040600@keyaccess.nl>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <20071113164650.GA28493@elte.hu> <4739E3D0.10201@rtr.ca> <20071118124404.GA4037@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Lord <liml@rtr.ca>, Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20071118124404.GA4037@ucw.cz>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18-11-07 13:44, Pavel Machek wrote:

> On Tue 2007-11-13 12:50:08, Mark Lord wrote:

>> It's a 540MByte download over a slow link for everyone 
>> else.
> 
> Hmmm, clean-cg is 7.7G on my machine, and yes I tried
> git-prune-packed. What am I doing wrong?

clean-cg? But failure to run "git repack -a -d" every once in a while?

Rene.
