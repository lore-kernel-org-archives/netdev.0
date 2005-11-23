From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] [PATCH 0/3] ioat: DMA engine support
Date: Wed, 23 Nov 2005 18:36:51 -0500
Message-ID: <4384FD13.7060606@pobox.com>
References: <Pine.LNX.4.44.0511231143380.32487-100000@isotope.jf.intel.com>	 <4384E7F2.2030508@pobox.com>  <20051123223007.GA5921@wotan.suse.de> <1132790740.13095.53.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, Andrew Grover <andrew.grover@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, christopher.leech@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751318AbVKWXg6@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1132790740.13095.53.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
> Might also be interesting to use one half of a hypedthread CPU as a
> copier using the streaming instructions, might be better than turning it
> off to improve performance ?

That's pretty interesting too...

	Jeff
