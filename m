From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: argh... ;/
Date: Fri, 12 Aug 2005 12:35:06 +0100
Message-ID: <20050812113506.GA2819@linux-mips.org>
References: <42F2D749.70306@gmail.com> <200508060241.30507.phillips@istop.com>
	<20050805172055.GB5641@tuxdriver.com>
	<20050812053634.GA3998@taniwha.stupidest.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-mentors@selenic.com, netdev <netdev@vger.kernel.org>,
        Daniel Phillips <phillips@istop.com>
Return-path: <kernel-mentors-bounces@selenic.com>
To: Chris Wedgwood <cw@f00f.org>
Content-Disposition: inline
In-Reply-To: <20050812053634.GA3998@taniwha.stupidest.org>
List-Unsubscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=unsubscribe>
List-Archive: <http://www.selenic.com/pipermail/kernel-mentors>
List-Post: <mailto:kernel-mentors@selenic.com>
List-Help: <mailto:kernel-mentors-request@selenic.com?subject=help>
List-Subscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=subscribe>
Sender: kernel-mentors-bounces@selenic.com
Errors-To: kernel-mentors-bounces@selenic.com
List-Id: netdev.vger.kernel.org

On Thu, Aug 11, 2005 at 10:36:34PM -0700, Chris Wedgwood wrote:

> On Fri, Aug 05, 2005 at 01:20:59PM -0400, John W. Linville wrote:
> 
> > Yes.  Opening attachments makes them harder to review.
> 
> Lots of people can't inline patches because they are inflicted with
> crappy MUAs --- I would much prefer patches as attachments in those
> cases versus mangled patches.
> 
> Also, I would arguue any sane MUA would make dealing with
> reading/openning patches for sensible mime types trivial.

That may break quilt import and probably other tools; having to teach quilt
about MIME would be a horribly pointless exercise.

  Ralf
