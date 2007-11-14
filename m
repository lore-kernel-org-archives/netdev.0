From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 17:10:51 -0800 (PST)
Message-ID: <20071113.171051.199524749.davem@davemloft.net>
References: <4739E3D0.10201@rtr.ca>
	<20071113181228.GF4250@stusta.de>
	<4739EA83.5040006@rtr.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, mingo@elte.hu, akpm@linux-foundation.org,
 protasnb@gmail.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
 alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
 linux-pcmcia@lists.infradead.org, linux-input@atrey.karlin.mff.cuni.cz,
 bugme-daemon@bugzilla.kernel.org
To: liml@rtr.ca
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <4739EA83.5040006@rtr.ca>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

From: Mark Lord <liml@rtr.ca>
Date: Tue, 13 Nov 2007 13:18:43 -0500

> Mind you, no arguing that this is effective when that poor bloke has
> a day free to download the git-tree and build/reboot a dozen times.

Like the internet, this time spent is beneficial because it's
pushing the work out to the end nodes.  In fact git bisect is
an awesome example of the end node principle in action for
software development and QA.

For the end-user wanting their bug fixed and the developer it's a win
win situation because the reporter is actually able to do something
proactive which will help get the bug they want fixed faster.

So I don't agree with framing this person as a "poor bloke".  Our
testers are more empowered than ever to lead the process towards a
fix.
