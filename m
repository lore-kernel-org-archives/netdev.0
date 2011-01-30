From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: batman-adv 2011-01-29
Date: Sun, 30 Jan 2011 03:56:56 -0800 (PST)
Message-ID: <20110130.035656.115941353.davem@davemloft.net>
References: <1296337660-12376-1-git-send-email-sven@narfation.org>
	<20110129.190815.226768755.davem@davemloft.net>
	<201101301036.57928.sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <201101301036.57928.sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Date: Sun, 30 Jan 2011 10:36:54 +0100

> On Sunday 30 January 2011 04:08:15 David Miller wrote:
>> I'm not taking 13 patches in one big bunch at this point post-merge-window,
>> now matter what they are.
> 
> Thats why I tried to provide the 6 bug fixes only version without polishing - 
> I could also try to reduce it to a 4 critical version (oops/memleak patches 
> only without protocol implementation failures).
> 
> Or is the problem that I tried to get them in as pull request?

Please make a new patch series posting and pull request with only the most
important fixes included.

Once I accept those, you can send me a second patch series and pull
request with the cleanups done on top.  Just mention explicitly in
this second pull request that there is a dependency upon the initial
bug fixes.  In this way I will know to pull net-2.6 into net-next-2.6
first, and then pull from your tree into net-next-2.6

Thanks.
