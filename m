From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] MAINTAINERS: Remove Sven Eckelmann from
	BATMAN ADVANCED
Date: Wed, 22 Jun 2011 01:16:20 -0700 (PDT)
Message-ID: <20110622.011620.1019772975075064501.davem@davemloft.net>
References: <1308661983-4113-1-git-send-email-sven@narfation.org>
	<20110621.143515.1651926143381429168.davem@davemloft.net>
	<28453742.RFlbu1Gcpv@sven-desktop.home.narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <28453742.RFlbu1Gcpv-1RWNDQYo44h8XcdJbWeDu3TFMtCCXL7YSoIsB4E12gc@public.gmane.org>
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
Date: Wed, 22 Jun 2011 09:41:45 +0200

> On Tuesday 21 June 2011 14:35:15 David Miller wrote:
>> All of this effort was placed to get this thing merged into the
>> main tree, and then moved out of staging.
> 
> "Shooting the messenger" - I think that is the matching phrase. Just try to 
> grep my name in the net/batman-adv/ and you will see it nowhere.

It is everywhere as far as I am concerned, because you're the only person
actually keeping upstream maintained and in sync.

> The problem is that I am probably the most unimportant person in the
> whole project.

>From my perspective, this is not true.  You are the most important
person.  And this is because the people writing the code obviously
don't care enough about upstream to do any merges themselves.  Yet
you do.

> But at least I was good enough to send some patches around which
> were accepted or made by other people. I was also not the person
> behind the whole Linux-merge thing, but only some kind of
> marionette.

When we agree to allow someone to merge something into the tree,
especially a significant piece of code like batman-adv, there are some
impressions we want to have beforehand.

And one such impression we want is that there is going to be someone
continuing to be active maintaing the code upstream, even after the
code is merged.

Otherwise we get "merge and run" scenerios.  As networking maintainer,
I've been burnt by this several times.

If you're the only person who had the energy and motivation to do the
merges of this code, then you're only person we know that can keep up
with the expectations we had when we agreed to merge the code.

If you step down, that trust has been broken, and we're left with a
rotting pile of poo in the tree because it's unlikely anyone else is
going to step up and keep things maintained upstream as you did.
