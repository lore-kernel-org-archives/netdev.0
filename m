From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: [Patch 2/3 2.5] e100: Configuration and user guide update
Date: Fri, 15 Oct 2004 08:55:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <468F3FDA28AA87429AD807992E22D07E02E60265@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <jgarzik@pobox.com>, "netdev" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Christoph Hellwig" <hch@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Good point. Will fix this next time around.

-----Original Message-----
From: Christoph Hellwig [mailto:hch@infradead.org] 
Sent: Friday, October 15, 2004 8:41 AM
To: Venkatesan, Ganesh
Cc: jgarzik@pobox.com; netdev
Subject: Re: [Patch 2/3 2.5] e100: Configuration and user guide update

>  This file describes the Linux* Base Driver for the Intel(R) PRO/100
Family of
> -Adapters, version 3.x.x.  This driver includes support for
Itanium(TM)-based 
> -systems.
> +Adapters, version 3.2.x.  This driver includes support for
Itanium(TM)2 and
> +EM64T systems.

It seems to work on lots of non-intel architectures nicely aswell. What
about killing this silly sentence?
