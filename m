From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: [bonding][1/3] Synchronizing 2.4-2.6
Date: Sat, 30 Aug 2003 22:01:08 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308302201.09003.shmulik.hen@intel.com>
References: <200308272000.39229.shmulik.hen@intel.com> <3F4D2355.8010803@pobox.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F4D2355.8010803@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 28 August 2003 12:32 am, Jeff Garzik wrote:
> Shmulik Hen wrote:
>
> > patch 6 - Update versions/contributions in header and bump
> > version
>
> applied... even though a non-described ifenslave.c change snuck
> into this patch.

This patch was supposed to put some order into a bunch of bug fix 
patches that went in without going through an official maintainer. I 
was afraid they're going to get lost, so I stuck the above into a 
patch. One of those patches fixed compilation problems on ia64 
architecture, but caused problems in a Red Hat release instead.
Since I didn't see a separate patch for that, I thought I'll put it 
here too. Didn't think it'll cause problems as it was a one-liner.
I'll learn eventually :). 


	Shmulik.
