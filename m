From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPVS' Kconfig LBLC and LBLCR configuration typo
Date: Mon, 14 Jul 2003 17:03:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030714170301.4ae9953a.davem@redhat.com>
References: <20030714140350.GB1389@telpin.com.ar>
	<3F130F84.8010104@drugphish.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: albertogli@telpin.com.ar, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Roberto Nibali <ratz@drugphish.ch>
In-Reply-To: <3F130F84.8010104@drugphish.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Jul 2003 22:16:04 +0200
Roberto Nibali <ratz@drugphish.ch> wrote:

> > --- Kconfig.orig	2003-07-14 10:32:06.000000000 -0300
> > +++ Kconfig	2003-07-14 10:32:57.000000000 -0300
> > @@ -147,7 +147,7 @@
> 
> Obviously correct. Dave, if you haven't already, please apply to your 
> tree, thanks. We're working on the 2.4.x patch ;).

Applied, I'm also still waiting for the timer fix
on the 2.5.x side.

The IPVS stuff went into 2.6.0-test1 BTW.
