From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] sk98lin: Driver update v7.09
Date: Wed, 27 Oct 2004 10:25:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027102519.0fc3c7a9@guest-251-240.pdx.osdl.net>
References: <417907C1.6050407@syskonnect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mirko Lindner <mlindner@syskonnect.de>
In-Reply-To: <417907C1.6050407@syskonnect.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Oct 2004 15:14:41 +0200
Mirko Lindner <mlindner@syskonnect.de> wrote:

> Hi dev-list,
> Hi Jeff,
> 
> here is the new version (v7.09) from our sk98lin driver for Kernel 2.6. 
> Sorry for this huge patch but this version has a lot of new functions 
> and changes. The driver was tested by our Test & Verification group and 
> our OEM customers and include all kernel changes during the latest 
> kernel release.
> 
> Please send me an email if you like a version of the driver for kernel 
> 2.4 or if you have any problems or questions.
> 
> The new patch for BK version 2.6.9 bk6 can be find at:
> http://www.syskonnect.de/support/temp/sk98lin_v7.09_2.6.9-bk6_patch

Since you won't...
I'll break this up in pieces (and merge in my changes), and get
rid of the UglyReDefineTheWorld style.
