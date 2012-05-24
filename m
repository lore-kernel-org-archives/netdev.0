From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 06/15] batman-adv: Distributed ARP Table
 - add snooping functions for ARP messages
Date: Thu, 24 May 2012 01:54:57 -0400 (EDT)
Message-ID: <20120524.015457.1543147002306809286.davem@davemloft.net>
References: <20120523214802.GA12222@pandem0nium>
	<20120523.190158.2172815395820691292.davem@davemloft.net>
	<3476925.EJY4MZoOgZ@sven-desktop.home.narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	lindner_marek-LWAfsSFWpa4@public.gmane.org
To: sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <3476925.EJY4MZoOgZ-1RWNDQYo44h8XcdJbWeDu3TFMtCCXL7YSoIsB4E12gc@public.gmane.org>
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
Date: Thu, 24 May 2012 07:34:12 +0200

> _You_ were the person that declined the pull request because _you_ wanted to 
> rewrite the ARP handling. So _you_ are the person that has the insight in 
> _your_ plans. Either _you_ tell us what is _your_ problem with it or _you_ 
> will have to point us to a person that knows _you_.

If I say that you must not use ARP nor neighbour layer internals, it
doesn't mean that I have to come up with the alternative
implementation for you.

Now, you can ask others on the netdev list for suggestions, but you
can't expect me to be the direct and only responder on things like
that.
