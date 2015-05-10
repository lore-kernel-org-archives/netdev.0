From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ARM: net: add JIT support for loads from struct
 seccomp_data.
Date: Sun, 10 May 2015 19:20:14 -0400 (EDT)
Message-ID: <20150510.192014.1958300550338396860.davem@davemloft.net>
References: <1431003613-16554-1-git-send-email-nschichan@freebox.fr>
	<20150509.222858.26253293963482182.davem@davemloft.net>
	<20150510194028.GA2067@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nschichan@freebox.fr, dborkman@redhat.com, ast@plumgrid.com,
	mgherzan@gmail.com, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150510194028.GA2067@n2100.arm.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Sun, 10 May 2015 20:40:28 +0100

> I think you have taken previous ARM net JIT patches, so I think it
> makes sense if you continue to do so.  I'm not knowledgable of the
> JIT interface myself, all I can say about many of these patches is
> that they look okay to me on a superficial basis.
> 
> I suspect you're doing more or less the same, but from a slightly
> different perspective (presumably through not knowing ARM assembly.)

Ok, I'll flow the ARM JIT patches through my tree then.

Thanks Russell.
