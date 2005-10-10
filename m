From: Matt Leininger <mlleinin@hpcn.ca.sandia.gov>
Subject: Re: Timeline of IPoIB performance
Date: Mon, 10 Oct 2005 16:44:57 -0700
Message-ID: <1128987897.13952.441.camel@localhost>
References: <1128672413.13948.326.camel@localhost>
	<52br20lsei.fsf@cisco.com> <1128738350.13945.369.camel@localhost>
	<521x2tgrim.fsf@cisco.com> <1128986707.13945.424.camel@localhost>
	<52br1xdjtm.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <rolandd@cisco.com>
In-Reply-To: <52br1xdjtm.fsf@cisco.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Mon, 2005-10-10 at 16:38 -0700, Roland Dreier wrote:
>     Matt>   Pretty consistent.  Here are a few runs with 2.6.12-rc5
>     Matt> with reboots in between each run.  I'm using netperf-2.3pl1.
> 
> That's interesting.  I'm guessing you're using mem-ful HCAs?

  Yes, I'm using mem-full HCAs.  I could try reflashing the firmware for
memfree if that's of interest.
> 
> Given that your results are more stable than mine, if you're up for
> it, you could install git, clone Linus's tree, and then do a git
> bisect between 2.6.12-rc4 and 2.6.12-rc5 to narrow down the regression
> to a single commit (if in fact that's possible).
  
 I was hoping someone else would do this.  :)
 
 I'll start working on it tomorrow if no one else gets to it.

  Thanks,

	- Matt
