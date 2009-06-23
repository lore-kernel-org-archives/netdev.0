From: Jake Edge <jake-T1hC0tSOHrs@public.gmane.org>
Subject: Re: [PATCH v3.1415] Documentation: add documentation summary for
 rc-series and merge window
Date: Tue, 23 Jun 2009 13:02:13 -0600
Message-ID: <20090623130213.36b8ba8e@chukar>
References: <20090622222217.GH23972@bombadil.infradead.org>
	<m3fxdqj2bz.fsf@lwn.net>
	<20090623175533.GK5305@mosca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Luis Rodriguez <Luis.Rodriguez-R2DSYHpuZhhBDgjK7y7TUQ@public.gmane.org>,
	"torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	"corbet-T1hC0tSOHrs@public.gmane.org" <corbet-T1hC0tSOHrs@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org" <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org" <tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org>
To: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090623175533.GK5305@mosca>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 23 Jun 2009 10:55:33 -0700 Luis R. Rodriguez wrote:

> You're right, thanks, will add that. Since you bring this up, are
> there a lot of trees not using the foo-next-2.6.git convention?

Hmm, it seems like I have seen a wide variety of tree names and/or
branch names included in the git pull requests ... also, the tree/branch
names used in linux-next:
http://linux.f-seidel.de/linux-next/pmwiki/pmwiki.php?n=Linux-next.IncludedTrees
seem to be all over the map ...

> > Again, seemingly too rigid based on what really happens ... but
> > maybe this is documenting the "ideal"
> 
> Well I take it that the maintainers who know they can get away with
> some excemptions here don't need to read this to figure that out. But
> I suppose it may be worth mentioning excemptions do exist, for the
> record. BTW, just curious, are there any examples of this?

I think you have created a new word: excemptions :)  I kinda like it,
but I think you mean exceptions.

I think there are multiple examples of new features being merged after
-rc1, but nothing comes to mind immediately ... I think the plan is to
only add features during the merge window, but it occasionally gets
overridden ...

> Yes, thanks. BTW are you up for taking a stab at this yourself? I'm
> not sure when I'll be able to again.

Jon may have some comments, when he has a chance to look ... let's see
where it goes from there ...

jake

-- 
Jake Edge - LWN - jake-T1hC0tSOHrs@public.gmane.org - http://lwn.net
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
