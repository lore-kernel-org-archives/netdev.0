From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.20 5/5] s2io: De-typedef driver.
Date: Tue, 23 Jan 2007 00:48:24 -0500
Message-ID: <45B5A1A8.3050606@garzik.org>
References: <Pine.GSO.4.10.10701190245210.22012-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leonid.grossman@neterion.com,
	alicia.pena@neterion.com, ramkrishna.vepa@neterion.com,
	sivakumar.subramani@neterion.com, sreenivasa.honnur@neterion.com,
	sriram.rapuru@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45375 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933009AbXAWFs0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 00:48:26 -0500
To: Ananda Raju <Ananda.Raju@neterion.com>
In-Reply-To: <Pine.GSO.4.10.10701190245210.22012-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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


