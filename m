From: jamal <hadi@cyberus.ca>
Subject: Re: How can we bound one CPU to one Gigabit NIC?
Date: Wed, 9 Oct 2002 22:22:05 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210092218370.16149-100000@shell.cyberus.ca>
References: <slrnaq667h.ntv.lunz@stoli.localnet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <slrnaq667h.ntv.lunz@stoli.localnet>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




On Tue, 8 Oct 2002, Jason Lunz wrote:

> hadi@cyberus.ca said:
> > Can you repeat these tests with NAPI and no binding and see if you get
> > any reordering?
>
> Wouldn't he need a NAPIfied SysKonnect driver? I wasn't aware anyone had
> converted it yet. Or is it enough for him to check the blog_dev path?

Duh. There is no NAPIfied SysKonnect driver ;->
Well he didnt bother responding, so he may have figured that out.
SysKonnect gige is a bad piece of hardware (bad csuming hware; we tried
to build a NIC out of it) so i wouldnt recommend for him to use it.

cheers,
jamal
