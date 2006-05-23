From: Simon Oosthoek <simon.oosthoek@ti-wmc.nl>
Subject: Re: [ANNOUNCE] FLAME: external kernel module for L2.5 meshing
Date: Tue, 23 May 2006 16:41:48 +0200
Message-ID: <44731F2C.2010109@ti-wmc.nl>
References: <44731733.7000204@ti-wmc.nl> <1148395738.25255.68.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herman Elfrink <herman.elfrink@ti-wmc.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from darla.ti-wmc.nl ([217.114.97.45]:9887 "EHLO smtp.wmc")
	by vger.kernel.org with ESMTP id S1751357AbWEWOlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 10:41:49 -0400
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1148395738.25255.68.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
> On Maw, 2006-05-23 at 16:07 +0200, Herman Elfrink wrote:
>> FLAME uses an unofficial protocol number (0x4040), any tips on how to 
>> get an official IANA number would be highly appreciated.
>>
> 
> Ethernet protocol number I assume you mean. If so this at least used to
> be handled by the IEEE, along with ethernet mac address ranges.
> 

Yes ethernet protocol (it's below IP level), I didn't realise that IEEE 
also handled the portnumbers. I'll check the ieee website to see how it 
works, tnx!

/Simon

