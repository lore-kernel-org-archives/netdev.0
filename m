From: Tomas Winkler <tomas_bw@yahoo.com>
Subject: Re: dscape git
Date: Mon, 17 Jul 2006 09:14:39 -0700 (PDT)
Message-ID: <20060717161439.38118.qmail@web60711.mail.yahoo.com>
References: <20060717151555.28384.qmail@web60718.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web60711.mail.yahoo.com ([209.73.178.214]:32934 "HELO
	web60711.mail.yahoo.com") by vger.kernel.org with SMTP
	id S1750924AbWGQQOk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jul 2006 12:14:40 -0400
To: Erik Mouw <erik@harddisk-recovery.com>
In-Reply-To: <20060717151555.28384.qmail@web60718.mail.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hmm, I've missed the second part of you email. 
The solution you've suggested has worked. 
Thanks
Anyhow if this is a problem of sync then it last for 2
days already.
Thanks a lot


--- Tomas Winkler <tomas_bw@yahoo.com> wrote:

> First I'm behind the firewall second other gits
> worked
> just fine.
> Thanks
> 
> --- Erik Mouw <erik@harddisk-recovery.com> wrote:
> 
> > On Mon, Jul 17, 2006 at 07:15:03AM -0700, Tomas
> > Winkler wrote:
> > > I've tried to clone dscape git and I got the
> error
> > > bellow. I hade no problem go get other trees.
> I'm
> > new
> > > to git so maybe I didn't use correct switches
> > > Command Line: git clone
> > >
> >
>
http://www.kernel.org/pub/scm/linux/kernel/git/jbenc/dscap
> > > e.git/ dscape
> > 
> > When available, use the git protocol. It's both
> > faster and more
> > efficient.
> > 
> > > Thanks for help
> > > 
> > > got 0cdcef84239e5f1d60310883688b7aeca5278875
> > > error: The requested file was not found
> > (curl_result =
> > > 22, http_code = 503, sha1
> > >  = 27fd37621255799602d74e94d670ff7a1658d40a)
> > > Getting pack list for
> > >
> >
>
http://www.kernel.org/pub/scm/linux/kernel/git/jbenc/dscap
> > > e.git/
> > > got 80f18b79eacc07319afe473023a5358cfbc11ae6
> > > Getting pack list for http://www.kernel.or
> > > error: The requested file was not found
> > > error: Unable to find
> > > 27fd37621255799602d74e94d670ff7a1658d40a under
> > > http://www.
> > >
> >
>
kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git/
> > > Cannot obtain needed blob
> > > 27fd37621255799602d74e94d670ff7a1658d40a
> > > while processing commit
> > a495f8ec7590d6df5edc36bff419f25b8c3440de.
> > 
> > Could be that www.kernel.org didn't yet fully sync
> > up with
> > master.kernel.org. Just wait, it usually gets
> > corrected in half an
> > hour.
> > 
> > I just succesfully clone'd dscape with the
> following
> > command line:
> > 
> > git clone --reference linux-2.6 \
> >  
> >
>
git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git
> > dscape
> > 
> > The "--reference" parameter tells git that I have
> a
> > local repository
> > called "linux-2.6" (which just follow Linus' 2.6
> > tree) which can be
> > used to pull the shared git objects from. Saves
> > quite some disk space.
> > 
> > 
> > Erik
> > 
> > -- 
> > +-- Erik Mouw -- www.harddisk-recovery.com -- +31
> 70
> > 370 12 90 --
> > | Lab address: Delftechpark 26, 2628 XH, Delft,
> The
> > Netherlands
> > -
> > To unsubscribe from this list: send the line
> > "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at 
> > http://vger.kernel.org/majordomo-info.html
> > 
> 
> 
> __________________________________________________
> Do You Yahoo!?
> Tired of spam?  Yahoo! Mail has the best spam
> protection around 
> http://mail.yahoo.com 
> -
> To unsubscribe from this list: send the line
> "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at 
> http://vger.kernel.org/majordomo-info.html
> 


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
