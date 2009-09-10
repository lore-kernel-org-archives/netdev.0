From: Daniel Walker <dwalker@fifo99.com>
Subject: Re: [PATCH 00/12] Gigaset driver patches for 2.6.32
Date: Wed, 09 Sep 2009 20:47:57 -0700
Message-ID: <1252554477.30578.167.camel@desktop>
References: <20090909223205.E9D632269516@fifo99.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	Hansjoerg Lipp <hjlipp@web.de>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754122AbZIJDrb@vger.kernel.org>
In-Reply-To: <20090909223205.E9D632269516@fifo99.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-09-10 at 00:32 +0200, Tilman Schmidt wrote:
> Daniel Walker wrote 07.09.09 16:30:
> > Yeah, it looks like the whole file needs a checkpatch clean up..
> Sounds
> like your not willing to do that?
> 
> It's not a question of willingness. You may notice I did a lot of
> cleanup work already. But it's very time consuming work, and there has
> been more important work to attend to first.
> 
> > Usually if a checkpatch cleanup comes
> first prior to all your other changes , it doesn't usually cloud the
> rest of the changes..
> 
> Sure. But that would mean postponing the merging of bugfixes until
> someone finds the time to do a complete checkpatch cleanup of the
> affected code. I don't think that's a sensible approach.

You shouldn't be adding any new checkpatch errors, but you currently
are .. Just clean up the individual patches w/o the entire gigaset
driver, that should be do-able (it's even a basic submission
requirement). The other issue is that your adding new files which aren't
clean, those can certainly be cleaned up.

Daniel
