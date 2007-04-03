From: "Peter Trifonov" <petert@dcn.infos.ru>
Subject: RE: PROBLEM: sky2 hangs
Date: Tue, 3 Apr 2007 19:19:08 +0400
Message-ID: <20070403151908.41E574AC7F@dcn.infos.ru>
References: <20070402124110.1c5f98d4@oldman>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "'Stephen Hemminger'" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-9cor.infos.ru ([195.209.229.106]:63803 "EHLO dcn.infos.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030319AbXDCPTS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 11:19:18 -0400
In-Reply-To: <20070402124110.1c5f98d4@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Stephen,
> > I have got a PC based on Gigabyte GA-965P-S3 motherboard with an 
> > integrated Marvell Yukon 88E8056 PCI-E gigabit ethernet controller.
> There have been several updates since 2.6.18. Please try and 
> reproduce with 2.6.20 or later kernel. Or contact the vendor 
> to update their kernel.

Thanks a lot!

After installing 2.6.20 kernel the NIC works perfectly!


With best regards,
P. Trifonov  


