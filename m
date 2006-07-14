From: Rick Jones <rick.jones2@hp.com>
Subject: Re: I/O Acceleration Technology Nics
Date: Fri, 14 Jul 2006 09:41:18 -0700
Message-ID: <44B7C92E.6050502@hp.com>
References: <d0383f90607140250u2e958470o4ba6b072dd57df3d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:57485 "EHLO palrel13.hp.com")
	by vger.kernel.org with ESMTP id S1161265AbWGNQlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 12:41:19 -0400
To: Ian Brown <ianbrn@gmail.com>
In-Reply-To: <d0383f90607140250u2e958470o4ba6b072dd57df3d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ian Brown wrote:
> Hello,
>  I came across the e1000 download for linux in intel site.
> I saw that in the readme they talk about Intel(R) I/O Acceleration 
> Technology;
> According to this readme , there is support for "systems using the
> Intel(R) 5000 Series Chipsets Integrated Device - 1A38".
> see:
> http://downloadmirror.intel.com/df-support/9180/ENG/README.txt
> 
> My question is : did anybody tried using chipsets with this I/O
> Acceleration Technology ?  Did he get a significant performance
> improvement over non I/O Accelerated nics ?

IIRC, there were some measures made and discussed at least a little in 
netdev.  A search of the archives should find them.

I would also expect that Intel would have some glossy PDF's on their 
site touting the performance boosts technology :)  They should at least 
somewhere have some links to actual measurements...

> Ian
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I suspect the URL above there will start one on the path to the email 
archive.

rick jones
