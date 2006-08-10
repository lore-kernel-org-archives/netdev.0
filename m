From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/9] [TULIP] Clean tulip.h so it can be used by winbond-840.c
Date: Thu, 10 Aug 2006 08:26:43 -0400
Message-ID: <44DB2603.5030208@garzik.org>
References: <20060807204418.GE401@athena.road.mcmartin.ca> <11549840122892-git-send-email-kyle@parisc-linux.org> <11549840321096-git-send-email-kyle@parisc-linux.org> <1154984032324-git-send-email-kyle@parisc-linux.org> <115498403384-git-send-email-kyle@parisc-linux.org> <44D9739E.905@garzik.org> <20060809150055.GA9316@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kyle McMartin <kyle@parisc-linux.org>, netdev@vger.kernel.org,
	val_henson@linux.intel.com, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:20190 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1161212AbWHJM0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 08:26:51 -0400
To: Grant Grundler <grundler@parisc-linux.org>
In-Reply-To: <20060809150055.GA9316@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Grant Grundler wrote:
> On Wed, Aug 09, 2006 at 01:33:18AM -0400, Jeff Garzik wrote:
>> 2) nobody (but parisc folks?) knows what CBMA and CBIO mean.  Just use 
>> "MMIO" and "PIO"
> 
> "CBIO" is what's in the public documentation. I just want to make it
> easy for anyone who bothers to read the documentation to be sure
> they are reading about the right register.

Thanks for clarifying.  Nonetheless, I still prefer 'mmio' and 'pio' 
because its more universal.

	Jeff



