From: Mark Lord <liml@rtr.ca>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 13:47:10 -0500
Message-ID: <4739F12E.5020807@rtr.ca>
References: <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <20071113164650.GA28493@elte.hu> <4739E3D0.10201@rtr.ca> <20071113181228.GF4250@stusta.de> <4739EA83.5040006@rtr.ca> <20071113183605.GG4250@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <20071113183605.GG4250@stusta.de>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
...
> I did bisecting myself, and I know that it costs time and work.
> 
> But the first point is the above one that it makes otherwise nearly 
> undebuggable problems debuggable and fixable.
..

Definitely useful, no question.

But the problem is now that kernel devs are addicted to it,
many won't even consider resolving a problem any other way.

That's not "maintaining" (or supporting) one's code.

And when a "maintainer" is too busy to find/fix their own bugs,
that could be a sign that they've bitten off too big of a chunk
of the kernel, and it's time for them to distribute code maintainership.

Cheers
