From: Matt Porter <mporter@kernel.crashing.org>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 22:51:29 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040915225129.B25752@home.com>
References: <4148991B.9050200@pobox.com> <Pine.LNX.4.61.0409152102050.23011@fogarty.jakma.org> <4148A561.5070401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Jakma <paul@clubi.ie>, Netdev <netdev@oss.sgi.com>,
	leonid.grossman@s2io.com,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S267405AbUIPFvv@vger.kernel.org>
To: Neil Horman <nhorman@redhat.com>
Content-Disposition: inline
In-Reply-To: <4148A561.5070401@redhat.com>; from nhorman@redhat.com on Wed, Sep 15, 2004 at 04:26:09PM -0400
List-Id: netdev.vger.kernel.org

On Wed, Sep 15, 2004 at 04:26:09PM -0400, Neil Horman wrote:
> IBM's PowerNP chip was also very simmilar (a powerpc core with lots of 
> hardware assists for DMA and packet inspection in the extended register 
> area).  Don't know if they still sell it, but at one time I had heard 
> they had booted linux on it.

Well, yes, PowerNP support has been in the kernel for years and embedded
Linux distros like Mvista support them.  It's no longer an IBM chip,
though.  AMCC purchased the PPC4xx network processors (PowerNP) from
IBM and later purchased the entire standard SoC PPC4xx product line
from IBM.  That is, except for the PPC4xx STB chips like are found in
the Hauppage MediaMVP, IBM retained those.  AMCC pretty much owns all
the PPC4xx line and PowerNP 405H/L are still available.

-Matt
