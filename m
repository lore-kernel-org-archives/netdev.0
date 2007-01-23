From: "Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>
Subject: RE: [PATCH 2.6.20 5/5] s2io: De-typedef driver.
Date: Tue, 23 Jan 2007 15:05:21 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77011EC535@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Leonid Grossman" <Leonid.Grossman@neterion.com>,
	"Alicia Pena" <Alicia.Pena@neterion.com>,
	"Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	"Sriram Rapuru" <Sriram.Rapuru@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [72.1.205.142] ([72.1.205.142]:44367 "EHLO owa.neterion.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S965482AbXAWUFW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 15:05:22 -0500
Content-class: urn:content-classes:message
To: "Jeff Garzik" <jeff@garzik.org>,
	"Ananda Raju" <Ananda.Raju@neterion.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

Thanks for the comments. We have implemented the comments and
resubmitted all five patch again.

Thanks,
~Siva 

-----Original Message-----
From: Jeff Garzik [mailto:jeff@garzik.org] 
Sent: Tuesday, January 23, 2007 11:18 AM
To: Ananda Raju
Cc: netdev@vger.kernel.org; Leonid Grossman; Alicia Pena; Ramkrishna
Vepa; Sivakumar Subramani; Sreenivasa Honnur; Sriram Rapuru
Subject: Re: [PATCH 2.6.20 5/5] s2io: De-typedef driver.

Ananda Raju wrote:
> Removed namespace collisions due to usage of nic_t as per Ralf's patch

> (ralf@linux-mips.org).
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>

ACK

Please make the following the first line of your email body:

From: Ralf Baechle <ralf@linux-mips.org>

That will tell the patch importer to properly credit Ralf as the patch's
author.

	Jeff


