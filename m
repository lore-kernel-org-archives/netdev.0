From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH -mm] __ratelimit rewrite
Date: Sun, 04 May 2008 19:25:05 -0700
Message-ID: <1209954305.13011.1.camel@localhost>
References: <20080504070738.GA11832@darkstar.te-china.tietoenator.com>
	 <1209912447.16966.42.camel@localhost>
	 <a8e1da0805041837q4a5264c6l7bc23dce1d3282fd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, paulmck@us.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dave Young <hidave.darkstar@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756615AbYEECv5@vger.kernel.org>
In-Reply-To: <a8e1da0805041837q4a5264c6l7bc23dce1d3282fd@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2008-05-05 at 09:37 +0800, Dave Young wrote:
> >  I think your changes should then be done in
> >  printk.h not creating a new ratelimit.h.
> 
> IMO ratelimit is not just for printk use now, so a standalone head
> file is necessary.

What other uses would ratelimit have?
