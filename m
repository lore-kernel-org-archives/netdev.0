From: Davide Libenzi <davidel-AhlLAIvw+VEjIGhXcJzhZg@public.gmane.org>
Subject: Re: 2.6.27-05178-g2e532d6: list_add corruption
Date: Sat, 18 Oct 2008 07:38:40 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0810180737100.21525@alien.or.mcafeemobile.com>
References: <a4423d670810171220t4d5602fekcb66e18758149925@mail.gmail.com>
 <Pine.LNX.4.64.0810171617490.21410@alien.or.mcafeemobile.com>
 <a4423d670810172341y5ae5542jea66ead938ba652d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <a4423d670810172341y5ae5542jea66ead938ba652d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 18 Oct 2008, Alexander Beregalov wrote:

> > This is very likely to be caused by a patch that went in a few days ago.
> > Already posted a fix to Andrew.
> >
> 
> Is it the same problem? 2.6.27-05577-g0cfd810

Hard to be sure, but certainly a double insert can create a similar 
problem. The only way to tell is to get the fix and retry.


- Davide
