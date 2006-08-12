From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.18-rc3-mm2 (+ hotfixes): GPF related to skge on suspend
Date: Sat, 12 Aug 2006 21:34:49 +0200
Message-ID: <200608122134.49687.rjw@sisk.pl>
References: <200608121207.42268.rjw@sisk.pl> <44DDDA2F.4080404@garzik.org> <200608121632.19070.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422650AbWHLTgP@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <200608121632.19070.rjw@sisk.pl>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 12 August 2006 16:32, Rafael J. Wysocki wrote:
> On Saturday 12 August 2006 15:39, Jeff Garzik wrote:
> > Andrew Morton wrote:
> > > It would be good if you could poke around in gdb, work out exactly which
> > > statement it's oopsing at, please.
> > 
> > I'm also interested to know if the problem goes away when you disable 
> > preempt...
> 
> That will take some time to test. :-)

It's also reproducible with PREEMPT disabled.
