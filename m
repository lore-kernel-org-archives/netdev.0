From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: Re: [patch 1/2] net/orinoco_plx: replace schedule_timeout() with ssleep()
Date: Mon, 7 Mar 2005 11:57:36 +1100
Message-ID: <20050307005736.GA19547@localhost.localdomain>
References: <20050306222140.6ACE51EC90@trashy.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: proski@gnu.org, netdev@oss.sgi.com, nacc@us.ibm.com,
        janitor@sternwelten.at
To: domen@coderock.org
Content-Disposition: inline
In-Reply-To: <20050306222140.6ACE51EC90@trashy.coderock.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Mar 06, 2005 at 11:21:40PM +0100, domen@coderock.org wrote:
> 
> Use ssleep() instead of schedule_timeout()
> to guarantee the task delays as expected.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
> Signed-off-by: Domen Puncer <domen@coderock.org>

Already in CVS, patch already sent to Jeff.  Likewise for orinoco_tmd.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist.  NOT _the_ _other_ _way_
				| _around_!
http://www.ozlabs.org/people/dgibson
