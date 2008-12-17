From: "Tvrtko A. Ursulin" <tvrtko@ursulin.net>
Subject: Re: Bonding gigabit and fast?
Date: Wed, 17 Dec 2008 07:37:12 +0000
Message-ID: <200812170737.12575.tvrtko@ursulin.net>
References: <200812161939.30033.tvrtko@ursulin.net> <4948119B.5050000@redhat.com> <200812162255.47731.tvrtko@ursulin.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mk-outboundfilter-4.mail.uk.tiscali.com ([212.74.114.32]:64526
	"EHLO mk-outboundfilter-4.mail.uk.tiscali.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752908AbYLQHhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 02:37:18 -0500
In-Reply-To: <200812162255.47731.tvrtko@ursulin.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 16 December 2008 22:55:47 Tvrtko A. Ursulin wrote:
> So this points to Samba/scheduler/CIFS client regression I think. I'll try
> to do more testing in the following days. All this assuming that ~22Mb/s is
> the best this machine can do and only hunting for slow and unstable speed
> over Samba.

In the morning I am not so sure about this any more. Problem is there is no 
regression with fast ethernet and it being faster than gigabit it moves the 
blame back to networking/skge.

Do you any ideas for further tests which could clarify this?

Thanks,

Tvrtko
