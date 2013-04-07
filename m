From: Eric Wong <normalperson-rMlxZR9MS24@public.gmane.org>
Subject: Re: net_dropmon usage documentation/examples?
Date: Sun, 7 Apr 2013 11:28:55 +0000
Message-ID: <20130407112855.GA2544@dcvr.yhbt.net>
References: <20130405193855.GA27775@dcvr.yhbt.net>
 <20130406123856.GA11355@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130406123856.GA11355-B26myB8xz7F8NnZeBjwnZQMhkBWG/bsMQH7oEaQurus@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
> On Fri, Apr 05, 2013 at 07:38:55PM +0000, Eric Wong wrote:
> > Hi Neil, I'm wondering if you have or know of any public
> > documentation/examples for using net_dropmon.
> > 
> > If not, I'll figure it out on my own at some point.
> > 
> > Thanks in advance!
> 
> I don't think there are any particular examples at the moment, but if you
> download the dropwatch utility, it uses the dropmon protocol to detect frame
> loss in the stack, and its use is pretty self explanitory, as is the perf script
> that uses the same tracepoints as the dropmon protocol.
> 
> 
> https://fedorahosted.org/dropwatch/

Thanks Neil!  I think I'll just use dropwatch directly instead of
writing my own code, now :)
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
