From: Deepak <deepakcse11@gmail.com>
Subject: Re: GSO / TSO offload dependency
Date: Wed, 5 Jun 2013 09:28:43 +0000 (UTC)
Message-ID: <loom.20130605T112420-606@post.gmane.org>
References: <de0a9dcb1002280900k728b241fyd72112defc0336ea@mail.gmail.com> <1267385446.2282.119.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:44557 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750698Ab3FFEFF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jun 2013 00:05:05 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UkRRe-0003Fs-AD
	for netdev@vger.kernel.org; Thu, 06 Jun 2013 06:05:03 +0200
Received: from 67-207-112-62.static.wiline.com ([67.207.112.62])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 06 Jun 2013 06:05:02 +0200
Received: from deepakcse11 by 67-207-112-62.static.wiline.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 06 Jun 2013 06:05:02 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > If hardware supports TSO, and  If TSO and GSO are both enabled, ...
> > what will happen to segmentation assembly by means of GSO ...
> > GSO will not do any segmentatoin assembly for TCP alone and will do
> > for other protocols ??  bit confused here? Please clarify.
> 
> Your understanding is correct.
> 
> Ben.
> 


I havn't understood this one, In case of TCP Protocol (Hardware support TSO 
and TSO & GSO are enabled), will it go through the GSO  segmentation assembly 
code ??
