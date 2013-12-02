From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net v4] xen-netback: fix fragment detection in checksum
 setup
Date: Mon, 2 Dec 2013 20:13:08 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD019CFFF@AMSPEX01CL01.citrite.net>
References: <1386005715-27566-1-git-send-email-paul.durrant@citrix.com>
 <20131202.134619.345791067738711031.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:24023 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753439Ab3LBUNL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 15:13:11 -0500
In-Reply-To: <20131202.134619.345791067738711031.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David Miller
> Sent: 02 December 2013 18:46
> To: Paul Durrant
> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Zoltan Kiss; Wei Liu;
> Ian Campbell; David Vrabel
> Subject: Re: [PATCH net v4] xen-netback: fix fragment detection in checksum
> setup
> 
> 
> You sent two copies of this patch, is there a difference between
> them?

Sorry. The SMTP server was playing up. The two copies are identical.

  Paul
