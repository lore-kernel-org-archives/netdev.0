From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [PATCH 0/2] igb: drop stats due to OS cannot keep
	up
Date: Fri, 15 May 2009 09:41:17 +0200
Message-ID: <1242373277.8675.8.camel@localhost.localdomain>
References: <1241703346.18487.22.camel@localhost.localdomain>
	<9929d2390905141543g6f5adc32ndf65870bd49d83ea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Ronciak,
	John" <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>, "Waskiewicz Jr,
	Peter P" <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <9929d2390905141543g6f5adc32ndf65870bd49d83ea@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, 2009-05-14 at 15:43 -0700, Jeff Kirsher wrote:
> Jesper - I have pulled in your patches, and made the necessary
> modifications based on Mitch's comments.  Right now, they are in
> testing and I should be pushing them to Dave in the next couple of
> days.

Sounds great! :-)

Do you or e1000-devel have a public git tree?
So I can work off that next time I have some changes, thus it would be
easier for you to merge in... (this time around I rebased my changes
each time some of you igb changes got into daveM's net-next-2.6 tree)

Cheers
-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


------------------------------------------------------------------------------
Crystal Reports - New Free Runtime and 30 Day Trial
Check out the new simplified licensing option that enables 
unlimited royalty-free distribution of the report engine 
for externally facing server and web deployment. 
http://p.sf.net/sfu/businessobjects
