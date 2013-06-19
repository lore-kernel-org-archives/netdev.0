From: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH] build some drivers only when compile-testing
Date: Wed, 19 Jun 2013 08:50:08 +0200
Message-ID: <51C154A0.6080104@suse.cz>
References: <1369214326-6558-1-git-send-email-jslaby@suse.cz> <20130523022327.GB6159@kroah.com> <519D8876.9050405@suse.com> <51BF6BFF.7050705@suse.cz> <20130618160427.GE28961@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Mahoney <jeffm-IBi9RG/b67k@public.gmane.org>, jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Alexander Shishkin <alexander.shishkin-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Florian Tobias Schandinat <FlorianSchandinat-Mmb7MZpHnFY@public.gmane.org>,
	linux-geode-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	"Keller, Jacob E" <jacob.e.keller-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Michal Marek <mmarek-AlSwsSmVLrQ@public.gmane.org>, tomi.valkeinen-l0cyMroinI0@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130618160427.GE28961-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/18/2013 06:04 PM, Greg Kroah-Hartman wrote:
>> So currently I have what is attached... Comments?
> 
> Looks good to me, want me to queue it up through my char/misc driver
> tree for 3.11?

If there are no objections... Whoever picks that up, I would be happy 8-).

-- 
js
suse labs
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
