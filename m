From: "Ravinandan Arakali" <Ravinandan.Arakali@neterion.com>
Subject: RE: pci_enable_msix throws up error
Date: Thu, 1 Jun 2006 15:08:41 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD777C0648@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Ravinandan Arakali" <Ravinandan.Arakali@neterion.com>,
	<linux-kernel@vger.kernel.org>,
	"Ananda. Raju" <ananda.raju@neterion.com>,
	<netdev@vger.kernel.org>,
	"Leonid Grossman" <Leonid.Grossman@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:57069 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S965297AbWFATIa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 15:08:30 -0400
Content-class: urn:content-classes:message
To: "Andi Kleen" <ak@suse.de>, "Ayaz Abdulla" <AAbdulla@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have submitted a proposed fix for the below issue.
Will wait for comments.

Ravi

-----Original Message-----
From: Andi Kleen [mailto:ak@suse.de]
Sent: Friday, May 05, 2006 1:44 AM
To: Ayaz Abdulla
Cc: ravinandan.arakali@neterion.com; linux-kernel@vger.kernel.org;
Ananda. Raju; netdev@vger.kernel.org; Leonid Grossman
Subject: Re: pci_enable_msix throws up error


On Friday 05 May 2006 07:14, Ayaz Abdulla wrote:
> I noticed the same behaviour, i.e. can not use both MSI and MSIX without
> rebooting.
> 
> I had sent a message to the maintainer of the MSI/MSIX source a few
> months ago and got a response that they were working on fixing it. Not
> sure what the progress is on it.

The best way to make progress faster would be for someone like you
who needs it to submit a patch to fix it then.

-Andi

