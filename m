From: Samuel Ortiz <samuel.ortiz@nokia.com>
Subject: Re: [RFC: 2.6 patch] net/irda/irias_object.c: remove unused exports
Date: Sat, 15 Apr 2006 22:35:33 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0604152235001.1212@irie>
References: <20060414114446.GL4162@stusta.de> <Pine.LNX.4.58.0604151157320.1032@irie>
 <20060415.022702.120267858.davem@davemloft.net>
Reply-To: samuel.ortiz@nokia.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: bunk@stusta.de, ext Jean Tourrilhes <jt@hpl.hp.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw-ext13.nokia.com ([131.228.20.172]:26007 "EHLO
	mgw-ext13.nokia.com") by vger.kernel.org with ESMTP
	id S1751388AbWDOTyg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Apr 2006 15:54:36 -0400
To: "ext David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060415.022702.120267858.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 15 Apr 2006, ext David S. Miller wrote:

> From: Samuel Ortiz <samuel.ortiz@nokia.com>
> Date: Sat, 15 Apr 2006 11:58:21 +0300 (EEST)
>
> > On Fri, 14 Apr 2006, ext Adrian Bunk wrote:
> >
> > > This patch removes the following unused EXPORT_SYMBOL's:
> > > - irias_find_attrib
> > > - irias_new_string_value
> > > - irias_new_octseq_value
> > >
> > > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> > Looks good to me.
> >
> > Signed-off-by: Samuel Ortiz <samuel.ortiz@nokia.com>
>
> Sam, just add this to your IRDA queue.  Ok?
Sure, I will.
