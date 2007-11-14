From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 17:41:06 -0700
Message-ID: <200711131741.06509.vda.linux@googlemail.com>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <20071113175610.GE4250@stusta.de> <4739F399.2010605@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>,
 Theodore Tso <tytso@mit.edu>,
 Benoit Boissinot <bboissin@gmail.com>,
 Mark Lord <liml@rtr.ca>,
 Ingo Molnar <mingo@elte.hu>,
 Andrew Morton <akpm@linux-foundation.org>,
 David Miller <davem@davemloft.net>,
 protasnb@gmail.com,
 linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org,
 alsa-devel@alsa-project.org,
 linux-ide@vger.kernel.org,
 linux-pcmcia@lists.infradead.org,
 linux-input@atrey.karlin.mff.cuni.cz,
 bugme-daemon@bugzilla.kernel.org
To: Gabriel C <nix.or.die@googlemail.com>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <4739F399.2010605@googlemail.com>
Content-Disposition: inline
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

On Tuesday 13 November 2007 11:57, Gabriel C wrote:
> > The main problem is finding experienced developers who spend time on
> > looking into bug reports.
>
> There are already. IMO the problem is the development model.
>
> There are tons new features in each new kernel release and 'tons new bugs'
> which are not fixed during the release cycle nor in the .XX stable kernels.
>
> Maybe after XX kernel releases there should be one just with bug-fixes
> _without_ any new features , eg: cleaning bugs from bugzilla , know
> regressions , cleaning up code , removing broken drivers and the like.

Won't work. You cannot force people to work on things they don't
find interesting, long-term.
--
vda
