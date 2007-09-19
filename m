From: maximilian attems <max@stro.at>
Subject: Re: bnx2 dirver's firmware images
Date: Wed, 19 Sep 2007 19:10:33 +0200
Message-ID: <20070919171033.GH6618@stro.at>
References: <46F01BDE.6020902@zytor.com> <20070918.122034.83625273.davem@davemloft.net> <46F02688.8030507@zytor.com> <20070918.130810.78161599.davem@davemloft.net> <20070918203530.GC27836@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hpa@zytor.com,
	mchan@broadcom.com, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:4596 "EHLO baikonur.stro.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751181AbXISRKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 13:10:35 -0400
Content-Disposition: inline
In-Reply-To: <20070918203530.GC27836@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Sep 2007, Sam Ravnborg wrote:

> Anyway - if we again consider klibc I will do my best to make the
> build stuff as smooth as possible.
> 
> 	Sam

<nitpicking mode on>
currently klibc has tendency to rebuild a bit too much if you
touch some part of it, seen in usr/utils
for the main klibc i agree that it makes sense

-- 
maks
