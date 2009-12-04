From: Caleb Cushing <xenoterracide@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Thu, 3 Dec 2009 20:49:17 -0500
Message-ID: <81bfc67a0912031749y15faed66s9c8a924684c97a19@mail.gmail.com>
References: <81bfc67a0911232217n41b9ac02w3b7770b789e5d209@mail.gmail.com>
	<20091124111946.GA7883@ff.dom.local>
	<81bfc67a0911250606k1ec76354n217da9ca20b3517c@mail.gmail.com>
	<20091125191105.GA3167@ami.dom.local>
	<81bfc67a0911271007o1fb8f8c2vdd36e8585280e4da@mail.gmail.com>
	<20091127213640.GA2611@ami.dom.local>
	<81bfc67a0911271435g4106652bpe8c9ea07893d0ebd@mail.gmail.com>
	<20091127224206.GA3350@ami.dom.local>
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
In-Reply-To: <20091127224206.GA3350@ami.dom.local>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

>
> modprobe -r e1000e
> modprobe e1000e IntMode=0
>
> Jarek P.
>
tested on kernel behaving properly no change. what do these modes do?

I've installed a 10/100 linksys nic into my system. it appears to be
working fine on a bad kernel (2.6.32-final tested and for sure
verified). I've only tested it once though. my laptop died so direct
connection between that won't work. can I test between these 2 nics?
(suppose no real reason why not) but what should I proceed with at
this point?


-- 
Caleb Cushing

http://xenoterracide.blogspot.com

------------------------------------------------------------------------------
Join us December 9, 2009 for the Red Hat Virtual Experience,
a free event focused on virtualization and cloud computing. 
Attend in-depth sessions from your desk. Your couch. Anywhere.
http://p.sf.net/sfu/redhat-sfdev2dev
