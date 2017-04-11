From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH net-next v4 1/5] netlink: extended ACK reporting
Date: Tue, 11 Apr 2017 10:57:23 +0200
Message-ID: <20170411085723.GE1976@nanopsycho>
References: <20170411065700.2623-1-johannes@sipsolutions.net>
 <20170411065700.2623-2-johannes@sipsolutions.net>
 <20170411071900.GC1976@nanopsycho>
 <1491895758.31620.4.camel@sipsolutions.net>
 <20170411081346.GD1976@nanopsycho>
 <1491899392.31620.14.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1491899392.31620.14.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tue, Apr 11, 2017 at 10:29:52AM CEST, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org wrote:
>On Tue, 2017-04-11 at 10:13 +0200, Jiri Pirko wrote:
>> Tue, Apr 11, 2017 at 09:29:18AM CEST, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
>> wrote:
>> > On Tue, 2017-04-11 at 09:19 +0200, Jiri Pirko wrote:
>> > > 
>> > > > +	NUM_NLMSGERR_ATTRS,
>> > > 
>> > > According to the rest of the uapi, this should be rather named:
>> > > 	__NLMSGERR_ATTR_MAX
>> > 
>> > nl80211 uses NUM_ so I guess that's a matter of convention, but I
>> > can
>> > change that I guess.
>> 
>> Please do.
>
>No further comments on any other parts of the patch(es)? :)

I didn't found anything aside the narrow descriptions- you have it like
that in 4 out of 5 patches :)


>
>I don't want to be resending all the time, so I guess I'll wait. For
>now, all code is in the nl-err branch in mac80211-next.
>
>johannes
