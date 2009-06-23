From: Jake Edge <jake-T1hC0tSOHrs@public.gmane.org>
Subject: Re: [PATCH v3.1415] Documentation: add documentation summary for
 rc-series and merge window
Date: Tue, 23 Jun 2009 13:23:16 -0600
Message-ID: <20090623132316.28a4a348@chukar>
References: <20090622222217.GH23972@bombadil.infradead.org>
	<m3fxdqj2bz.fsf@lwn.net>
	<m3bpoen5pp.fsf@intrepid.localdomain>
	<20090623130602.6cd6b713@chukar>
	<alpine.LFD.2.01.0906231210040.3240@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	"Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	"corbet-T1hC0tSOHrs@public.gmane.org" <corbet-T1hC0tSOHrs@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org" <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org" <tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.2.01.0906231210040.3240-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 23 Jun 2009 12:11:52 -0700 (PDT) Linus Torvalds wrote:

> In fact, this whole discussion has shown one thing: people still
> think that "bug fix" somehow automatically means that it's
> appropriate after the merge window. That's simply not so. 

Makes sense.  It certainly is counter-intuitive sometimes, though.
Just to clarify, there would seem to be one other category of bugs that
is reasonable post-merge-window: those introduced by new features (or
bug fixes) that were added during the merge window (i.e. something
found in testing the new code during the -rc cycle). Those don't
necessarily have to be security/oops problems and, for the most part,
can't be regressions (at least for new features).  Or should those
wait, by and large, for the next merge window?

jake

-- 
Jake Edge - LWN - jake-T1hC0tSOHrs@public.gmane.org - http://lwn.net
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
