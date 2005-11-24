From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [RFC] [PATCH 1/3] ioat: DMA subsystem
Date: Thu, 24 Nov 2005 16:00:50 +0100
Message-ID: <200511241600.50046.netdev@axxeo.de>
References: <Pine.LNX.4.44.0511231207410.32487-100000@isotope.jf.intel.com> <4384F0C4.1090209@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Grover <andrew.grover@intel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	christopher.leech@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932081AbVKXPA6@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4384F0C4.1090209@pobox.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Jeff Garzik wrote:
> explanation of this function would be nice.  remember to answer "how?" 
> and "why?", not "what?".

Wasn't it the other way around?
Citing linux/Documentation/CodingStyle, section 7 "Comments":

"Generally, you want your comments to tell WHAT your code does, not HOW."

HOW and WHY should be obvious by the source code, unless
the sources are a mess.


Regards

Ingo Oeser
