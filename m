From: Steve Fox <drfickle@us.ibm.com>
Subject: Re: 2.6.19-rc1: known regressions (v2) - xfrm_register_mode
Date: Mon, 09 Oct 2006 10:32:34 -0500
Message-ID: <1160407954.1984.11.camel@flooterbu>
References: <Pine.LNX.4.64.0610042017340.3952@g5.osdl.org>
	 <20061007214620.GB8810@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Mel Gorman <mel@skynet.ie>,
	Vivek Goyal <vgoyal@in.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932940AbWJIPcl@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061007214620.GB8810@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-10-07 at 23:46 +0200, Adrian Bunk wrote:
> Subject    : oops in xfrm_register_mode
> References : http://lkml.org/lkml/2006/10/4/170
> Submitter  : Steve Fox <drfickle@us.ibm.com>
> Status     : unknown

Status: Vivek and Mel have both created patches which fix the boot
issue, but it is not clear to me if either of these are acceptable
fixes.

-- 

Steve Fox
IBM Linux Technology Center
