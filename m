From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: bnx2 dirver's firmware images
Date: Tue, 18 Sep 2007 13:40:55 -0700
Message-ID: <46F037D7.5020202@zytor.com>
References: <46F01BDE.6020902@zytor.com> <20070918.122034.83625273.davem@davemloft.net> <46F02688.8030507@zytor.com> <20070918.130810.78161599.davem@davemloft.net> <20070918203530.GC27836@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	vda.linux@googlemail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:37809 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391AbXIRUlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 16:41:10 -0400
In-Reply-To: <20070918203530.GC27836@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sam Ravnborg wrote:
> 
> Except there seems to be great resistance to include userland code in the
> kernel as demonstrated at last KS. Or this is maybe just a single vocal
> person and the topic were brought up late?
> 
> Anyway - if we again consider klibc I will do my best to make the
> build stuff as smooth as possible.
> 

At least as of the last merged tree it was very smooth indeed, thanks to
your help.

	-hpa
