From: Caleb Cushing <xenoterracide@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Fri, 27 Nov 2009 17:35:34 -0500
Message-ID: <81bfc67a0911271435g4106652bpe8c9ea07893d0ebd@mail.gmail.com>
References: <81bfc67a0911232217n41b9ac02w3b7770b789e5d209@mail.gmail.com>
	<20091124111946.GA7883@ff.dom.local>
	<81bfc67a0911250606k1ec76354n217da9ca20b3517c@mail.gmail.com>
	<20091125191105.GA3167@ami.dom.local>
	<81bfc67a0911271007o1fb8f8c2vdd36e8585280e4da@mail.gmail.com>
	<20091127213640.GA2611@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Frans Pop <elendil@planet.nl>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20091127213640.GA2611@ami.dom.local>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> I doubt bisecting is a good idea with so unpredictable bug. First, you
> should make sure it's not a hardware problem, so go back to the kernel
> you trust most, and give it a really long try with a few recompilations
> after slightly changing the config. Btw, I wonder if you tried e1000e
> module parameters like IntMode=0 or 1.

no, how do I set those?


-- 
Caleb Cushing

http://xenoterracide.blogspot.com

------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
