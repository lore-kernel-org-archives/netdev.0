From: Mirko Lindner <demon@pro-linux.de>
Subject: Re: [PATCH] sk98lin: Driver update v7.09
Date: Mon, 25 Oct 2004 23:38:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417D7259.2020800@pro-linux.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@infradead.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 22, 2004 at 03:14:41PM +0200, Mirko Lindner wrote:
 >> Hi dev-list,
 >> Hi Jeff,
 >>
 >> here is the new version (v7.09) from our sk98lin driver for Kernel 2.6.
 >> Sorry for this huge patch but this version has a lot of new functions
 >> and changes. The driver was tested by our Test & Verification group and
 >> our OEM customers and include all kernel changes during the latest
 >> kernel release.
 >>
 >> Please send me an email if you like a version of the driver for kernel
 >> 2.4 or if you have any problems or questions.
 >>
 >> The new patch for BK version 2.6.9 bk6 can be find at:
 >> http://www.syskonnect.de/support/temp/sk98lin_v7.09_2.6.9-bk6_patch

 > Standard disclaimer:  please submit small incremental patches that fix
 > specific issue.


Sorry for the big patch but it's not possible to split the driver into
small pieces. As mentioned the submission isn't a bugfix release of the
old v6 driver with small additions. The new version 7.09 is a new driver
based on the old sk98lin driver with a support for two new chipsets from
Marvell (Yukon EC and Yukon FE). Yes, I know. The patch is huge but the
Yukon chipset has a different buffer handling and many register and hw
changes

I will be out of the office till Thursday. After the LWE we will merge
the new changes from Stephen into the new driver version. We have also
small fixes for the 7.09 and I think I'll release the 7.10 at the end of
the next week.

Mirko
