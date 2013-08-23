From: Rui Xiang <rui.xiang@huawei.com>
Subject: Re: [PATCH 0/2] fs: supply inode uid/gid setting interface
Date: Fri, 23 Aug 2013 15:32:30 +0800
Message-ID: <5217100E.6080506@huawei.com>
References: <1377226118-43756-1-git-send-email-rui.xiang@huawei.com> <20130823041010.GA12296@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-fsdevel@vger.kernel.org>, <viro@zeniv.linux.org.uk>,
        <linux-kernel@vger.kernel.org>, <linux-ia64@vger.kernel.org>,
        <linuxppc-dev@lists.ozlabs.org>, <linux-s390@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <linux-usb@vger.kernel.org>,
        <v9fs-developer@lists.sourceforge.net>, <linux-mm@kvack.org>,
        <cgroups@vger.kernel.org>, <netdev@vger.kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20130823041010.GA12296@kroah.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 2013/8/23 12:10, Greg KH wrote:
> On Fri, Aug 23, 2013 at 10:48:36AM +0800, Rui Xiang wrote:
>> This patchset implements an accessor functions to set uid/gid
>> in inode struct. Just finish code clean up.
> 
> Why?
> 
It can introduce a new function to reduce some codes. 
 Just clean up. 


Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
