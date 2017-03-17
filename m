From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: pull-request: mac80211 2017-03-16
Date: Fri, 17 Mar 2017 09:05:57 +0100
Message-ID: <1489737957.2544.1.camel@sipsolutions.net>
References: <20170316095156.31253-1-johannes@sipsolutions.net>
         <20170316.111819.199681647414354942.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170316.111819.199681647414354942.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-03-16 at 11:18 -0700, David Miller wrote:
> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Date: Thu, 16 Mar 2017 10:51:55 +0100
> 
> > Here's the pull request you were waiting for. I went through all my
> > pending patches but only this one is applicable for net.git at this
> > time, so it's just a single one.
> > 
> > Since I didn't have a current base, I forwarded to net.git first
> > and re-validated the patch there, but you might might have to be
> > careful if you merge to not fast-fwd on your side (though, even
> > if you do that, I don't think it matters much).
> > 
> > Please pull and let me know if there's any problem.
> 
> I was able to fast-forward pull this, so it should be fine.

Great, thanks. I somehow thought that you might _not_ want the fast
forward, to preserve where the patch came from, but personally I don't
care.

Thanks for merging it so quickly!

johannes
