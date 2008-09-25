From: Sebastien Dugue <sebastien.dugue@bull.net>
Subject: Re: [git patches] net driver updates for .28
Date: Thu, 25 Sep 2008 08:55:56 +0200
Message-ID: <20080925085556.4c430028@bull.net>
References: <20080924230710.GA22856@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, torvalds@gtf.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Klein <osstklei@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753335AbYIYG4X@vger.kernel.org>
In-Reply-To: <20080924230710.GA22856@havoc.gtf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  Hi Jeff,

On Wed, 24 Sep 2008 19:07:10 -0400 Jeff Garzik <jeff@garzik.org> wrote:


> Sebastien Dugue (2):
>       ehea: fix phyp debugging typo


>       ehea: fix mutex and spinlock use

        ^^^^^^

  That last one was NACKed by Thomas Klein (http://lkml.org/lkml/2008/9/15/81)
who asked for it to be reverted.

  Thanks,

  Sebastien.
