From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: net-PA Semi: Deletion of unnecessary checks before the function
 call "pci_dev_put"
Date: Tue, 02 Dec 2014 17:53:28 +0100
Message-ID: <1417539208.1841.1.camel@sipsolutions.net>
References: <5307CAA2.8060406@users.sourceforge.net>
	  <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
	  <530A086E.8010901@users.sourceforge.net>
	  <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
	  <530A72AA.3000601@users.sourceforge.net>
	 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
	  <530B5FB6.6010207@users.sourceforge.net>
	  <alpine.DEB.2.10.1402241710370.2074@hadrien>
	  <530C5E18.1020800@users.sourceforge.net>
	  <alpine.DEB.2.10.1402251014170.2080@hadrien>
	  <530CD2C4.4050903@users.sourceforge.net>
	  <alpine.DEB.2.10.1402251840450.7035@hadrien>
	  <530CF8FF.8080600@users.sourceforge.net>
	  <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
	  <530DD06F.4090703@users.sourceforge.net>
	  <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	  <5317A59D.4@users.sourceforge.net>
	 <547BC5AD.6090500@users.sourceforge.net>
	  (sfid-20141201_023451_153915_6CFB474F) <1417465745.28610.0.camel@sipsolutions.net>
	 <alpine.DEB.2.02.1412012134290.2076@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: SF Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>,
	Olof Johansson <olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	backports-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Luis R. Rodriguez" <mcgrof-IBi9RG/b67k@public.gmane.org>
To: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
Return-path: <backports-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.02.1412012134290.2076-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: backports-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-12-01 at 21:34 +0100, Julia Lawall wrote:

> > So this kind of evolution is no problem for the (automated) backports
> > using the backports project - although it can be difficult to detect
> > such a thing is needed.
> 
> That is exactly the problem...

I'm not convinced though that it should stop such progress in mainline.

johannes
