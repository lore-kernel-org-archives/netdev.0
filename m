From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: batman-adv 2012-04-07
Date: Tue, 10 Apr 2012 14:26:26 -0400 (EDT)
Message-ID: <20120410.142626.796731994824309878.davem@davemloft.net>
References: <1333824598-27771-1-git-send-email-ordex@autistici.org>
	<20120410.122119.454371140692964064.davem@davemloft.net>
	<4234545.h1xVgDKcJ2@bentobox>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <4234545.h1xVgDKcJ2@bentobox>
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
Date: Tue, 10 Apr 2012 20:03:43 +0200

> On Tuesday, April 10, 2012 12:21:19 PM David Miller wrote:
>> From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
>> Date: Sat,  7 Apr 2012 20:49:42 +0200
>> 
>> > this is the updated and cleaned up version of our last pull request
>> > (sent on 2012-04-05).
>> 
>> You absolutely must base your tree off the correct tree, which is
>> net-next
>> 
>> You cannot use Linus's tree or my 'net' tree to base your work,
>> because otherwise when I pull I get all the damn crap that's in those
>> trees but not in net-next yet and that's never right.
> 
> Can you please tell us your "stable point" [1].

Please, just base your work on the current tip of net-next like the
rest of the networking developers do.  I haven't once ever had to
talk about "stable point" or anything like that, you just simply
work against the tip of my tree and that's the end of it.
