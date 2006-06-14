From: Erik Mouw <erik@harddisk-recovery.com>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Wed, 14 Jun 2006 16:29:04 +0200
Message-ID: <20060614142903.GI11542@harddisk-recovery.com>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com> <20060613140716.6af45bec@localhost.localdomain> <20060613052215.B27858@openss7.org> <448F2A49.5020809@google.com> <20060614133022.GU11863@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Phillips <phillips@google.com>, bidulock@openss7.org,
	Stephen Hemminger <shemminger@osdl.org>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dtp.xs4all.nl ([80.126.206.180]:19563 "HELO abra2.bitwizard.nl")
	by vger.kernel.org with SMTP id S964961AbWFNO3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 10:29:06 -0400
To: Harald Welte <laforge@gnumonks.org>
Content-Disposition: inline
In-Reply-To: <20060614133022.GU11863@sunbeam.de.gnumonks.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 14, 2006 at 03:30:22PM +0200, Harald Welte wrote:
> On Tue, Jun 13, 2006 at 02:12:41PM -0700, Daniel Phillips wrote:
>  
> > This has the makings of a nice stable internal kernel api.  Why do we want
> > to provide this nice stable internal api to proprietary modules?
> 
> because there is IMHO legally nothing we can do about it anyway.  Use of
> an industry-standard API that is provided in multiple operating system
> is one of the clearest idnication of some program _not_ being a
> derivative work.

IMHO there is no industry-standard API for in-kernel use of sockets.
There is however one for user space.


Erik
(IANAL, etc)

-- 
+-- Erik Mouw -- www.harddisk-recovery.com -- +31 70 370 12 90 --
| Lab address: Delftechpark 26, 2628 XH, Delft, The Netherlands
