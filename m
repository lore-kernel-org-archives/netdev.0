From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Patches required for 3.9 stable
Date: Sat, 22 Jun 2013 07:45:18 -0700
Message-ID: <20130622144518.GA11334@kroah.com>
References: <51BEC1C3.40109@redhat.com>
 <20130617.132057.1873879604917526327.davem@davemloft.net>
 <20130622103954.GA2003@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jasowang@redhat.com,
	netdev@vger.kernel.org, mst@redhat.com, jwboyer@redhat.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:40924 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242Ab3FVOog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jun 2013 10:44:36 -0400
Content-Disposition: inline
In-Reply-To: <20130622103954.GA2003@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 22, 2013 at 12:39:54PM +0200, Francois Romieu wrote:
> David Miller <davem@davemloft.net> :
> > From: Jason Wang <jasowang@redhat.com>
> [...]
> > I'm currently working on stable submissions for networking.  The
> > person to ask for this kind of stuff is me, not Greg.
> 
> Is there a way (git, http, mailing list) to know where things are when
> a patch has been removed from patchwork [1] and has not appeared in
> Greg's tree [2] ?

Usually it's only a week or so at the most that this gap happens, why
does it matter?

You can watch the stable@vger.kernel.org mailing list and see the
submission by David of the patches, and then my ack of them later when
they hit my tree, is that sufficient?

thanks,

greg k-h
