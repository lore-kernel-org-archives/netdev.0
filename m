From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: Use setup_timer instead of init_timer
Date: Thu, 16 Mar 2017 10:54:32 +0100
Message-ID: <1489658072.2370.1.camel@sipsolutions.net>
References: <1488803104.5761.6.camel@sipsolutions.net>
         <20170309093436.25227-1-ondrej.lysonek@seznam.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ondrej.lysonek-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170309093436.25227-1-ondrej.lysonek-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-03-09 at 10:34 +0100, ondrej.lysonek-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org wrote:
> From: Ondřej Lysoněk <ondrej.lysonek-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org>
> 
> Use setup_timer() and setup_deferrable_timer() to set the data and
> function timer fields. It makes the code cleaner and will allow for
> easier change of the timer struct internals.
> 
Applied, thanks.

johannes
