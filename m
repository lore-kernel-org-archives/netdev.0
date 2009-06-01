From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.30rc7: ksoftirqd CPU saturation (x86-64 only,
 not x86-32) (e1000e-related?)
Date: Sun, 31 May 2009 21:58:55 -0700 (PDT)
Message-ID: <20090531.215855.142666346.davem@davemloft.net>
References: <87prdozxns.fsf@hades.wkstn.nix>
	<20090531170350.1355b3f1.akpm@linux-foundation.org>
	<87ljoczu3p.fsf@hades.wkstn.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: nix@esperi.org.uk
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <87ljoczu3p.fsf@hades.wkstn.nix>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Nix <nix@esperi.org.uk>
Date: Mon, 01 Jun 2009 01:16:26 +0100

> I plan to try out 2.6.29 (and back to 2.6.25 or thereabouts) tomorrow
> and see if it ever worked: if it did I'll bisect for it (rendered tricky
> by the out-of-tree e1000e driver, but doable: it would be easier if I
> had a clue where the e1000-devel git tree is, if anywhere, but I still
> have no idea despite considerable searching).

Why are you using the out-of-tree e1000e driver?  What's wrong
with the one in the tree? :-)

------------------------------------------------------------------------------
Register Now for Creativity and Technology (CaT), June 3rd, NYC. CaT 
is a gathering of tech-side developers & brand creativity professionals. Meet
the minds behind Google Creative Lab, Visual Complexity, Processing, & 
iPhoneDevCamp as they present alongside digital heavyweights like Barbarian 
Group, R/GA, & Big Spaceship. http://p.sf.net/sfu/creativitycat-com 
