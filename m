From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/2] fs: supply inode uid/gid setting interface
Date: Thu, 22 Aug 2013 21:10:10 -0700
Message-ID: <20130823041010.GA12296@kroah.com>
References: <1377226118-43756-1-git-send-email-rui.xiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
	linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-usb@vger.kernel.org,
	v9fs-developer@lists.sourceforge.net, linux-mm@kvack.org,
	cgroups@vger.kernel.org, netdev@vger.kernel.org
To: Rui Xiang <rui.xiang@huawei.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1377226118-43756-1-git-send-email-rui.xiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 23, 2013 at 10:48:36AM +0800, Rui Xiang wrote:
> This patchset implements an accessor functions to set uid/gid
> in inode struct. Just finish code clean up.

Why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
