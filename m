From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] [PATCH 0/3] ioat: DMA engine support
Date: Wed, 23 Nov 2005 17:56:45 -0500
Message-ID: <4384F3AD.4080105@pobox.com>
References: <Pine.LNX.4.44.0511231143380.32487-100000@isotope.jf.intel.com>	 <4384E7F2.2030508@pobox.com> <1132786445.13095.32.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Grover <andrew.grover@intel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	christopher.leech@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030473AbVKWW4z@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1132786445.13095.32.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
>>Additionally, current IOAT is memory->memory.  I would love to be able 
>>to convince Intel to add transforms and checksums, 
> 
> 
> Not just transforms but also masks and maybe even merges and textures
> would be rather handy 8)


Ah yes:  I totally forgot to mention XOR.

Software RAID would love that.

	Jeff
