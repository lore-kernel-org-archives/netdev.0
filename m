From: Mathieu Lacage <mathieu.lacage-0GlwE4rufLnvuXihggDW+w@public.gmane.org>
Subject: Re: [PATCH 12/12 net-2.6.25] [NETNS]: Add namespace for ICMP
	replying code.
Date: Wed, 23 Jan 2008 10:16:29 +0100
Message-ID: <1201079789.10778.26.camel@mistigri.inria.fr>
References: <479612BE.8030409@openvz.org>
	<1201074387-7366-3-git-send-email-den@openvz.org>
	<20080122.235130.84789113.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080122.235130.84789113.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

hi,

On Tue, 2008-01-22 at 23:51 -0800, David Miller wrote:
> From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> Date: Wed, 23 Jan 2008 10:46:27 +0300
> 
> > All needed API is done, the namespace is available when required from the
> > device on the DST entry from the incoming packet. So, just replace init_net
> > with proper namespace.
> > 
> > Other protocols will follow.
> > 
> > Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> 
> Applied, thanks.

I have been following the netns patches on this ML for a while but I
still have not figured out in which tree the patches fed to David Miller
are applied. I have attempted to grep the public trees 'davem/net-2.6'
and 'davem/net-2.6.25' but without much success so far. Is there a
public git tree I can clone which contains all the netns patches which
David Miller state are 'Applied' ?

thank you,
Mathieu
