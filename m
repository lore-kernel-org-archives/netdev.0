From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [Linux-ATM-General] [PATCH] ATM - fix seqfile compile failure
Date: Fri, 05 Sep 2003 14:14:45 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309051814.h85IEiSa011949@ginger.cmf.nrl.navy.mil>
References: <levon@movementarian.org>
Cc: netdev@oss.sgi.com, shemminger@osdl.org,
   linux-atm-general@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: John Levon <levon@movementarian.org>
In-Reply-To: Message from John Levon <levon@movementarian.org>
   of "Fri, 05 Sep 2003 18:51:13 BST." <20030905175113.GA40730@compsoc.man.ac.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>The recent conversion to seq_file breaks CONFIG_ATM_BR2684_IPFILTER
>compile. 

i sent in a patch for this already.  i did a bit of testing.

>I have absolutely no idea what the original author was attempting to
>achieve with the "pos" thing, btw ... *shrug*

the "pos" stuff was used by the old proc interface.
