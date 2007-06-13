From: "Ron Mercer" <ron.mercer@qlogic.com>
Subject: RE: [PATCH 2/3] qla3xxx: cleanup checksum offload code
Date: Wed, 13 Jun 2007 12:55:14 -0700
Message-ID: <0BB3E5E7462EEA4295BC02D49691DC07C82B54@AVEXCH1.qlogic.org>
References: <467048EF.1060001@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:30984 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414AbXFMTz5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 15:55:57 -0400
Content-class: urn:content-classes:message
In-Reply-To: <467048EF.1060001@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ACK patch #2, not patch 3.  I will add patch 3 at a later date.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

> -----Original Message-----
> From: Jeff Garzik [mailto:jeff@garzik.org] 
> Sent: Wednesday, June 13, 2007 12:44 PM
> To: Stephen Hemminger
> Cc: Linux Driver; netdev@vger.kernel.org
> Subject: Re: [PATCH 2/3] qla3xxx: cleanup checksum offload code
> 
> Stephen Hemminger wrote:
> > The code for checksum is more complex than needed when 
> dealing with VLAN's;
> > the higher layers already pass down the location of the IP header.
> > 
> > Compile tested only, no hardware available.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Ron, do you ACK patch #2 and patch #3?
> 
> 
> 
