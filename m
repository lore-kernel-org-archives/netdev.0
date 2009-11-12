From: Stephen Clark <sclark46@earthlink.net>
Subject: Re: [PATCH v2] Documentation: rw_lock lessons learned
Date: Thu, 12 Nov 2009 14:13:03 -0500
Message-ID: <4AFC5E3F.7070609@earthlink.net>
References: <4AF9C540.5090403@gmail.com>	<20091110180646.2e5859a8@nehalam>	<4AFAEF78.4080807@gmail.com> <20091111093724.4f40a48d@nehalam> <4AFBEC44.9030409@gmail.com>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753555AbZKLTNJ@vger.kernel.org>
In-Reply-To: <4AFBEC44.9030409@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

William Allen Simpson wrote:
> In recent weeks, two different network projects erroneously
> strayed down the rw_lock path.  Update the Documentation
> based upon comments by Eric Dumazet and Paul E. McKenney in
> those threads.
> 
> Merged with editorial changes by Stephen Hemminger.
> 
> Signed-off-by: William.Allen.Simpson@gmail.com
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> ---
>  Documentation/spinlocks.txt |  186 
> ++++++++++++++++++++-----------------------
>  1 files changed, 86 insertions(+), 100 deletions(-)
> 

How up to date is this doc?

http://www.kernel.org/pub/linux/kernel/people/rusty/kernel-locking/index.html

Should it be in the Documentation directory?


-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)
