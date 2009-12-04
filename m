From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Sat, 5 Dec 2009 00:47:57 +0100
Message-ID: <20091204234756.GA3517@ami.dom.local>
References: <20091125191105.GA3167@ami.dom.local>
	<81bfc67a0911271007o1fb8f8c2vdd36e8585280e4da@mail.gmail.com>
	<20091127213640.GA2611@ami.dom.local>
	<81bfc67a0911271435g4106652bpe8c9ea07893d0ebd@mail.gmail.com>
	<20091127224206.GA3350@ami.dom.local>
	<81bfc67a0912031749y15faed66s9c8a924684c97a19@mail.gmail.com>
	<20091204090524.GB6478@ff.dom.local>
	<81bfc67a0912041028w16668d0cx4da04bee989eef4a@mail.gmail.com>
	<20091204204443.GA2736@ami.dom.local>
	<81bfc67a0912041507k6ef497f9w7b9294c90012e1a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Frans Pop <elendil@planet.nl>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Caleb Cushing <xenoterracide@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <81bfc67a0912041507k6ef497f9w7b9294c90012e1a1@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, Dec 04, 2009 at 06:07:42PM -0500, Caleb Cushing wrote:
> > So, again, if you're willing to debug this, the new bugzilla report
> > seems reasonable to me, plus maybe some notice to this #11998 too.
> 
> I will later today. I'm thinking since I now have 2 active nics...
> would hooking the 1 card directly to the other and then running the
> tests be helpful? (I wish this mobo had a 3rd pci slot because I'd
> have put a 3rd card in so I can connect to the net at the same time.

I guess, you should better wait with new tests for some assistance
from e1000e maintainers - it seems they might be interested in some
specific dumps and registers - like in this #11998 case.

Jarek P.

------------------------------------------------------------------------------
Join us December 9, 2009 for the Red Hat Virtual Experience,
a free event focused on virtualization and cloud computing. 
Attend in-depth sessions from your desk. Your couch. Anywhere.
http://p.sf.net/sfu/redhat-sfdev2dev
