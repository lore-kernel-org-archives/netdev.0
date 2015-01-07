From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH] Fix NUL (\0 or \x00) specification in string
Date: Wed, 7 Jan 2015 13:22:58 +0100
Message-ID: <20150107122258.GG24104@suse.cz>
References: <1420394722-20197-1-git-send-email-me@mortis.eu>
 <20150105150026.GG6114@twin.jikos.cz>
 <20150106192804.GL4806@salidar.dom.custoft.eu>
Reply-To: dsterba@suse.cz
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	"open list:ISDN SUBSYSTEM" <netdev@vger.kernel.org>
To: Giel van Schijndel <me@mortis.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150106192804.GL4806@salidar.dom.custoft.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 06, 2015 at 08:28:04PM +0100, Giel van Schijndel wrote:
> On Mon, Jan 05, 2015 at 16:00:26 +0100, David Sterba wrote:
> > I'm replying to all your recent patches here as they are fixing things
> > reported in http://www.viva64.com/en/b/0299/ . I'ts a good practice to
> > give the credit the reporter.
> > 
> > The blogpost also contains analyses of the issues so it could help
> > reviewing the patches.
> 
> I guess you suggest I use a 'Reported-(at|by)' line?

A link in the changelog would be enough IMHO.

> Would something like the below suffice? I found similar log entries in the
> commit log, e.g. bf3204cb, except that those add an e-mail address for
> the reporters, which I don't think is necessary in this case.

If you don't have the emails, then rather do not use reported-by.
