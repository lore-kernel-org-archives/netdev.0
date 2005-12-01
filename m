From: Franck <vagabon.xyz@gmail.com>
Subject: Re: [PATCH] Add MIPS dependency for dm9000 driver
Date: Thu, 1 Dec 2005 09:05:58 +0100
Message-ID: <cda58cb80512010005h24c3754ex@mail.gmail.com>
References: <cda58cb80511300918i7df1c60au@mail.gmail.com>
	 <20051130132757.36e1cca0.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750760AbVLAIGA@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20051130132757.36e1cca0.akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew

2005/11/30, Andrew Morton <akpm@osdl.org>:
> Franck <vagabon.xyz@gmail.com> wrote:
> >
> > The attached patch adds MIPS dependency for dm9000 ethernet
> > controller. Indeed this controller is used by some embedded platforms
> > based on MIPS CPUs.
> >
>
> Is there any reason why we cannot enable this driver on all architectures?
>
> It's moderately important for quality and maintainability reasons that it
> be included in the x86 build, at least..
>

Actually there's a discussion about that. I previously sent a RFC
(subject is "[NET] Remove ARM dependency for dm9000 driver") for that.
Now some people are reacting so we should wait for the last words
before applying something.

thanks
--
               Franck
