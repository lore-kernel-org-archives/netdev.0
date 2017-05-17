From: Bastian Bittorf <bb-j3O8QLukP0Q@public.gmane.org>
Subject: Re: 'iw events' stops receiving events after a while on 4.9 + hacks
Date: Wed, 17 May 2017 12:08:45 +0200
Message-ID: <20170517100844.GC2849@medion.lan>
References: <d82d191e-8ede-68c6-c9e0-c381dc874d36@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <d82d191e-8ede-68c6-c9e0-c381dc874d36-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org> [17.05.2017 11:51]:
> I have been keeping an 'iw events' program running with a perl script gathering its
> output and post-processing it.  This has been working for several years on 4.7 and earlier
> kernels, but when testing on 4.9 overnight, I notice that 'iw events' is not showing any input.  'strace' shows
> that it is waiting on recvmsg.  If I start a second 'iw events' then it will get
> wifi events as expected.

me too, also seen on 4.4 - i'am happy for debug ideas.

bye, bastian
