From: Dave Jones <davej@redhat.com>
Subject: Re: kernel BUG at include/net/netns/generic.h:41
Date: Thu, 26 Apr 2012 10:06:53 -0400
Message-ID: <20120426140653.GA2111@redhat.com>
References: <20120328002346.GB3077@redhat.com>
 <20120402172600.GA3728@redhat.com>
 <1333390230.13718.34.camel@lade.trondhjem.org>
 <4F7DC37F.7090404@parallels.com>
 <20120405161241.GA23658@redhat.com>
 <4F7DC4CC.9080502@parallels.com>
 <20120425225855.GA5537@redhat.com>
 <4F98EA72.6010300@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F98EA72.6010300@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 26, 2012 at 10:25:54AM +0400, Stanislav Kinsbursky wrote:
 
 > >   >  >
 > >   >  >    >   2) how often do you experience this problem? Not every boot, I suppose?
 > >   >  >    >   3) And is it easy for you to reproduce?
 > >   >  >
 > >   >  >  It happens most the time, but not every time.
 > >   >
 > >   >  Ok, I'll send the patch soon.
 > >   >  Hope, it will help.
 > >
 > > I didn't see a follow-up patch on this, and I'm still seeing the BUG in rc4.
 > >
 > Dave, search for "SUNRPC: register PipeFS file system after pernet 
 > sybsystem" in your mail.
 > You are in CC list.

ah, missed that somehow.
I see it's now in Linus' tree too,

Thanks,

	Dave
