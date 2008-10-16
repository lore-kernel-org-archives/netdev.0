From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: deadlocks if use htb
Date: Thu, 16 Oct 2008 08:40:27 +0000
Message-ID: <20081016084027.GA17632@ff.dom.local>
References: <20081010075640.GA5204@ff.dom.local> <48EF17EA.5020306@bigtelecom.ru> <20081010090426.GA6054@ff.dom.local> <20081010095129.GB6054@ff.dom.local> <48F6FB3E.7060903@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:34411 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbYJPIkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 04:40:33 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1610166ugf.37
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2008 01:40:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48F6FB3E.7060903@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 16, 2008 at 12:28:46PM +0400, Badalian Vyacheslav wrote:
...
> Sorry for long answer.
> 
> We have troubles with power in our server place. Now its gone and i will
> test again all this.
> 
> With patch +  htb_hysteresis=0 and htb_hysteresis=1 without patch all PC
> work done 2 days and 18 hours. After this we have power crash.... =(

No need to hurry: you've written it's not everyday. Better try to make
sure there is really a diffrence after any of these changes.

Thanks,
Jarek P.
