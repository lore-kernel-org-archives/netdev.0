From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Fri, 21 Jan 2005 15:20:27 -0600
Message-ID: <200501211520.28409.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <200501201114.49517.jeremy.guthrie@berbee.com> <16880.10330.49064.721090@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16880.10330.49064.721090@robur.slu.se>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 20 January 2005 03:53 pm, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > >  >    mc GC: tot ignored goal_miss ovrf HASH: in_search out_search
>  > >  > 524287     74830     777     0     0     0     0     0         6   
>  > >  >    0 0     498       0         0    0           40504          1
>  >
>  > When does GC normally ignore?
>
>  At a min ip_rt_gc_min_interval       = HZ / 2;
>
>  From what I understand your GC runs more often than that.
>  Do your understand? Test is in rt_garbage_collect()
I'll look in the function and let you know if I have any questions.

Thanks

-- 

--------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711
