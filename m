From: Jake Edge <jake-T1hC0tSOHrs@public.gmane.org>
Subject: Re: [PATCH v3.1415] Documentation: add documentation summary for
 rc-series and merge window
Date: Tue, 23 Jun 2009 13:06:02 -0600
Message-ID: <20090623130602.6cd6b713@chukar>
References: <20090622222217.GH23972@bombadil.infradead.org>
	<m3fxdqj2bz.fsf@lwn.net>
	<m3bpoen5pp.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, "corbet\@lwn.net" <corbet-T1hC0tSOHrs@public.gmane.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"akpm\@linux-foundation.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"alan\@lxorguk.ukuu.org.uk" <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	"linux-wireless\@vger.kernel.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"tshibata\@ab.jp.nec.com" <tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org>
To: Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <m3bpoen5pp.fsf-gTjgKJgtlHj77SC2UrCW1FMQynFLKtET@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 23 Jun 2009 20:52:02 +0200 Krzysztof Halasa wrote:

> Perhaps it's just me :-) but I think we're trying to codify the rules
> way too much. The general rules (merge window = new features etc) are
> obviously ok but why do we need strict details like intrusive vs
> non-intrusive etc? People should just use a common sense and good
> judgement and, if in doubt in some particular case, ask. We are unable
> to describe all situations in a single text file.

Me2 :)

That may be a flaw in some parts of this doc is that it tries to
get too detailed, too rigid, etc. for a process that is more fluid and
has lots of independent parts each working in its own slightly
different way.  It does seem like there is value in much of what's
here, but there just aren't any black-and-white rules for exactly how
patches are handled.

jake

-- 
Jake Edge - LWN - jake-T1hC0tSOHrs@public.gmane.org - http://lwn.net
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
