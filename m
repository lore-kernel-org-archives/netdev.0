From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: networking bugs and bugme.osdl.org
Date: Fri, 27 Jun 2003 17:38:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <35240000.1056760723@[10.10.2.4]>
References: <20030626.224739.88478624.davem@redhat.com><21740000.1056724453@[10.10.2.4]><Pine.LNX.4.55.0306270749020.4137@bigblue.dev.mcafeelabs.com><20030627.143738.41641928.davem@redhat.com><Pine.LNX.4.55.0306271454490.4457@bigblue.dev.mcafeelabs.com><20030627213153.GR501@phunnypharm.org> <20030627162527.714091ce.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidel@xmailserver.org, davem@redhat.com, linux-kernel@vger.kernel.org,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@digeo.com>, Ben Collins <bcollins@debian.org>
In-Reply-To: <20030627162527.714091ce.akpm@digeo.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I also.  The bug database tries to convert the traditional many<->many
> debugging process into a one<->one process.  This surely results in a
> lower cleanup rate.

I think your suggestion of sending new bugs out to LKML has made a big
dent in the one<->one problem already. Replacing all the default owner 
fields with mailing lists (either existing ones or new ones) instead of 
individuals would be another step in that direction, though there may
be a few hurdles to deal with on the way to that.

Yes, we probably also need an "email back in" interface as we've 
discussed before to take it up to many-many.

> It is nice to have a record.  But bugzilla is not a comfortable or
> productive environment within which to drill down into and fix problems.

OK ... But I'd rather try to fix it than to throw the baby out with the 
bath water. I don't believe it's "unfixable" - the concept of tracking
bugs / problems and making sure they're closed out still seems sound to me.

As an example, I've seen several examples already where I've pestered 
people about bugs that already had patches attatched to them that resulted 
in "oh, yeah, I forgot to actually submit that", and it's got fixes back 
into mainline. I find it somewhat hard to believe that just about every
other big project (including open source ones) uses some form of bug 
tracking system, and yet Linux is somehow magically different ;-)

M.
