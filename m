From: Martin Langer <martin-langer@gmx.de>
Subject: Re: [PATCH]: bcm43xx-d80211: fix hwcrypto issues (mcast)
Date: Fri, 17 Nov 2006 23:59:01 +0100
Message-ID: <20061117225901.GB3951@tuba>
References: <ej09qf$2nv$1@sea.gmane.org> <200611120934.28133.mb@bu3sch.de> <20061114142959.GA17486@keitarou> <200611161507.33971.mb@bu3sch.de> <1163749589.5826.5.camel@localhost.localdomain> <1163750030.4047.1.camel@ux156> <1163750573.5826.7.camel@localhost.localdomain> <jeveles6lx.fsf@sykes.suse.de> <1163761482.4047.4.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Schwab <schwab@suse.de>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	netdev@vger.kernel.org,
	Paul TBBle Hampson <Paul.Hampson@pobox.com>,
	linville@tuxdriver.com, Michael Buesch <mb@bu3sch.de>,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.de ([213.165.64.20]:22440 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S1756022AbWKQW7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 17:59:06 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1163761482.4047.4.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 17, 2006 at 12:04:42PM +0100, Johannes Berg wrote:
> On Fri, 2006-11-17 at 11:35 +0100, Andreas Schwab wrote:
> 
> > Still the same.  One of them does not exist, the other one requires
> > Javascript!
> 
> Yeah, looks like Martin forgot to put the URLs in the the readme while
> he put them into commit messages...

The last update for README was quite some time ago. I think that file 
is a bad way to transport that kind of information. So I'm afraid a lot 
of links are really out of date now. A better way is probably an open 
wiki (berlios?). Volunteers and other ideas are always welcome.

The comments in the commit messages are more a kind of protocol and not 
the best link on earth. And if you wait some days the number of mirrors 
for the latest driver will explode. It would be bad to write the first 
available link into the README. A download link should be a direct 
link, a small package, easy to extract and so on. But I'm really not 
interested in doing that job of a hunter for the perfect download link 
and try to keep that link up to date. I think it's more important to 
write support for more driver files instead of doing that surrounding 
stuff for a few files in a perfect way. Google isn't that complicated 
these days and it's more up to date than our README.
 
> Support for bcmwl5.sys v4.80.53.0 added.
> ftp://downloads.netgear.com/files/wn511b_sw_3_28_3_8_setup.zip
> (bcmwl5.sys is renamed to wn511b.sys)
> 
> Support for bcmwl5(64).sys v4.100.15.5 added.
> >from the latest Linksys WPC300N driver at
> http://www.linksys.com/download/
> It's ucode revision 0x0173, patchlevel 0x0425, 2006-10-04.
> 
> Martin, can you add these to the readme?

These are bad examples for adding to README. People aren't prepared 
well enough to look for renamed bcmwl5.sys files which are packaged 
twice and they expect direct links, too. ...

Martin
