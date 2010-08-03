From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [GIT PULL] xen-netfront driver updates for 2.6.36
Date: Tue, 03 Aug 2010 11:12:54 -0700
Message-ID: <4C585C26.1050100@goop.org>
References: <4C585BC8.5070203@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	"Xen-devel@lists.xensource.com" <Xen-devel@lists.xensource.com>,
	"Xu, Dongxiao" <dongxiao.xu@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C585BC8.5070203@goop.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  On 08/03/2010 11:11 AM, Jeremy Fitzhardinge wrote:
>  Hi Dave,
>
> Here's a git branch with some updates to the Xen netfront driver, 
> which add a new "smartpoll" mode to the netfront backend protocol, 
> which is basically equivalent to interrupt mitigation.  They've been 
> in linux-next for a week or so.

Oops, never mind.

They got left out of linux-next, and they have a merge conflict.  I'll 
sort it out and resubmit.

'Thanks,
     J
