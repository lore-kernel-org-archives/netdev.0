From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Re: [PATCH-SR9700] Merge USB 1.1 Ethernet Adapter SR9700
 DeviceDriver into the Linux Kernel
Date: Wed, 21 Aug 2013 09:20:38 -0700
Message-ID: <20130821162038.GB14364@kroah.com>
References: <201308201841116403992@163.com>
 <20130820204606.GB26241@electric-eye.fr.zoreil.com>
 <201308211805574844059@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	sunhecheng <sunhecheng@vip.126.com>,
	linux-usb <linux-usb@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: liujunliang_ljl <liujunliang_ljl@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201308211805574844059@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 21, 2013 at 06:06:02PM +0800, liujunliang_ljl wrote:
> Dear Francois Romieu :
> 
> 	1, all the format problems have been fixed
> 	
> 	2, sr9700.h registers definition is re-written
> 
> 	3, Thanks for your detail checking and I have beed scripts/checkpatch.pl the patch and please check it.
> 
> [PATCH] :

You still aren't sending the patch in a format in which we can apply it
in.  Please read the file, Documentation/SubmittingPatches, specifically
the part about the "Signed-off-by:" line, and provding a proper body of
the patch for the changelog.

thanks,

greg k-h
