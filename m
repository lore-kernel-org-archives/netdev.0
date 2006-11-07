From: Andrew Morton <akpm@osdl.org>
Subject: Re: [take23 2/5] kevent: Core files.
Date: Tue, 7 Nov 2006 14:16:57 -0800
Message-ID: <20061107141657.b2378218.akpm@osdl.org>
References: <1162918248891@2ka.mipt.ru>
	<11629182482529@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753767AbWKGWTS@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <11629182482529@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 7 Nov 2006 19:50:48 +0300
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> This patch includes core kevent files:
>  * userspace controlling
>  * kernelspace interfaces
>  * initialization
>  * notification state machines

I fixed up all the rejects, but your syscall numbers changed.  Please
always raise patches against the latest kernel.
