From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH net-next v5 4/5] netlink: pass extended ACK struct to
 parsing functions
Date: Wed, 12 Apr 2017 15:20:36 +0200
Message-ID: <1492003236.2855.5.camel@sipsolutions.net>
References: <20170412123408.22012-1-johannes@sipsolutions.net>
         <20170412123408.22012-5-johannes@sipsolutions.net>
         <20170412131708.GC1952@nanopsycho> (sfid-20170412_151713_065465_26DD76A7)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170412131708.GC1952@nanopsycho> (sfid-20170412_151713_065465_26DD76A7)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-04-12 at 15:17 +0200, Jiri Pirko wrote:
> Wed, Apr 12, 2017 at 02:34:07PM CEST, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
> wrote:
> > From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > 
> > Pass the new extended ACK reporting struct to all of the
> 
> Johannes, I wonder, is there a reason you ignore my comments about
> narrow descriptions? Why don't you use the whole line?

I don't think it makes sense. Text is easier to read if it's narrower,
80 columns was never desired (only 72), and frankly, I think discussing
the commit or comment line length is pretty useless.

johannes
