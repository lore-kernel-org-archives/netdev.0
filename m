From: Simon Oosthoek <simon.oosthoek@ti-wmc.nl>
Subject: Re: [ANNOUNCE] FLAME: external kernel module for L2.5 meshing
Date: Tue, 23 May 2006 17:00:40 +0200
Message-ID: <44732398.1010701@ti-wmc.nl>
References: <44731733.7000204@ti-wmc.nl> <1148395738.25255.68.camel@localhost.localdomain> <44731F2C.2010109@ti-wmc.nl> <20060523145549.GA22749@harddisk-recovery.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Herman Elfrink <herman.elfrink@ti-wmc.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from darla.ti-wmc.nl ([217.114.97.45]:43424 "EHLO smtp.wmc")
	by vger.kernel.org with ESMTP id S932228AbWEWPAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 11:00:41 -0400
To: Erik Mouw <erik@harddisk-recovery.com>
In-Reply-To: <20060523145549.GA22749@harddisk-recovery.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Erik Mouw wrote:
> On Tue, May 23, 2006 at 04:41:48PM +0200, Simon Oosthoek wrote:
>> Alan Cox wrote:
>>> On Maw, 2006-05-23 at 16:07 +0200, Herman Elfrink wrote:
>>>> FLAME uses an unofficial protocol number (0x4040), any tips on how to 
>>>> get an official IANA number would be highly appreciated.
>>>>
>>> Ethernet protocol number I assume you mean. If so this at least used to
>>> be handled by the IEEE, along with ethernet mac address ranges.
>>>
>> Yes ethernet protocol (it's below IP level), I didn't realise that IEEE 
>> also handled the portnumbers. I'll check the ieee website to see how it 
>> works, tnx!
> 
> IEEE doesn't handle port numbers. Port numbers are for whatever is
> layered on top of ethernet, so you need to register those with the
> appropriate authorities (IANA for IP).
> 

Sorry, that was a typo and a thinko, I usually think above IP, my 
colleague is more used to under IP ;-)

/Simon

-- 
phone:(+31|0)53 4810319
fax:  (+31|0)53 4810333
simon.oosthoek@ti-wmc.nl
http://www.ti-wmc.nl/
