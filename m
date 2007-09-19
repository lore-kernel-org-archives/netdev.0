From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: bnx2 dirver's firmware images
Date: Wed, 19 Sep 2007 10:12:38 -0700
Message-ID: <46F15886.6040701@zytor.com>
References: <46F01BDE.6020902@zytor.com> <20070918.122034.83625273.davem@davemloft.net> <46F02688.8030507@zytor.com> <20070918.130810.78161599.davem@davemloft.net> <20070918203530.GC27836@uranus.ravnborg.org> <20070919171033.GH6618@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sam Ravnborg <sam@ravnborg.org>,
	David Miller <davem@davemloft.net>, mchan@broadcom.com,
	vda.linux@googlemail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: maximilian attems <max@stro.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:56666 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbXISRNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 13:13:17 -0400
In-Reply-To: <20070919171033.GH6618@stro.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

maximilian attems wrote:
> On Tue, 18 Sep 2007, Sam Ravnborg wrote:
> 
>> Anyway - if we again consider klibc I will do my best to make the
>> build stuff as smooth as possible.
>>
>> 	Sam
> 
> <nitpicking mode on>
> currently klibc has tendency to rebuild a bit too much if you
> touch some part of it, seen in usr/utils
> for the main klibc i agree that it makes sense
> 

Could you give a concrete example?

	-hpa
