From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [2.6 patch] fix bridge <-> ATM compile error
Date: Mon, 28 Mar 2005 11:11:31 -0800
Message-ID: <20050328111131.2f511a85@dxpl.pdx.osdl.net>
References: <20050316181532.GA3251@stusta.de>
	<200503172036.j2HKadfm000732@ginger.cmf.nrl.navy.mil>
	<20050319230458.GB18495@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas3@users.sourceforge.net, bridge@osdl.org,
	linux-atm-general@lists.sourceforge.net, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261992AbVC1TMX@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050319230458.GB18495@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 20 Mar 2005 00:04:58 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> On Thu, Mar 17, 2005 at 03:36:40PM -0500, chas williams - CONTRACTOR wrote:
> > In message <20050316181532.GA3251@stusta.de>,Adrian Bunk writes:
> > >Letting CONFIG_BRIDGE depend on CONFIG_ATM doesn't sound like a good 
> > >idea, since I doubt all people using the Bridge code require ATM 
> > >support.
> > 
> > how about the following?
> >...
> 
> Looks good

Ditto
