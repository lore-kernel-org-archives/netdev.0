From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 20:46:42 +0200
Message-ID: <200804152046.44018.oliver@neukum.org>
References: <20080414213238.GB28833@kroah.com> <1208271789.20681.45.camel@FWR-FLAB> <20080415153408.GB7996@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Filip Aben <f.aben@option.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	ajb@spheresystems.co.uk
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:53020 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753421AbYDOSrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 14:47:11 -0400
In-Reply-To: <20080415153408.GB7996@kroah.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 15. April 2008 17:34:08 schrieb Greg KH:
> So I'll go delete that "special" ioctl, that's not a good thing to do,
> use the common interfaces that all USB devices rely on instead, don't do
> something different for just one type of USB device.

Do you have a new unified patch? I'd work against that, lest we get
merge troubles.

	Regards
		Oliver

