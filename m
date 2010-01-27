From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Hang: 2.6.32.4 sky2/DMAR (was [PATCH] sky2: Fix WARNING: at
 lib/dma-debug.c:902 check_sync)
Date: Wed, 27 Jan 2010 20:32:20 +0100
Message-ID: <20100127193220.GB3135@del.dom.local>
References: <20100122234656.GC3105@del.dom.local>
 <4B5A39BD.8020305@majjas.com>
 <20100123232133.GA3487@del.dom.local>
 <4B605D1B.60402@majjas.com>
 <20100127085049.5b5048e9@nehalam>
 <4B60707F.1000608@majjas.com>
 <20100127095614.14313677@nehalam>
 <4B608128.7090607@majjas.com>
 <4B6089C7.4010803@majjas.com>
 <20100127192312.GA3135@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754248Ab0A0Tc3@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100127192312.GA3135@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 27, 2010 at 08:23:12PM +0100, Jarek Poplawski wrote:
> Stephen, I'm not sure this patch can show much after the patch with
> "legal" dma_size == re->data_addr didn't help. It looks like David

Of course: "dma_size == re->data_size".

Jarek P.
