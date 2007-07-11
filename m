From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH 0/5] more about numa_node with struct device
Date: Wed, 11 Jul 2007 15:06:16 -0700
Message-ID: <86802c440707111506q522f3f1dra242c8fa6a8f8b2d@mail.gmail.com>
References: <200707101652.20613.yinghai.lu@sun.com>
	 <20070711094034.GC19061@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "Christoph Hellwig" <hch@infradead.org>,
	"Yinghai Lu" <Yinghai.Lu@sun.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Andi Kleen" <ak@suse.de>, "Greg KH" <greg@kroah.com>,
	rientjes@google.com, "Christoph Lameter" <clameter@sgi.com>,
	"David Miller" <davem@davemloft.net>,
	"Stefan Richter" <stefanr@s5r6.in-berlin.de>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:58998 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762142AbXGKWGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 18:06:17 -0400
Received: by wa-out-1112.google.com with SMTP id v27so2489137wah
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 15:06:16 -0700 (PDT)
In-Reply-To: <20070711094034.GC19061@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/11/07, Christoph Hellwig <hch@infradead.org> wrote:
> On Tue, Jul 10, 2007 at 04:52:19PM -0700, Yinghai Lu wrote:
> > these are revised or new patch with numa_node in struct device in addition to
>
> Do you have a pointer to a background posting why you want all this?

http://lkml.org/lkml/2007/6/29/246
http://lkml.org/lkml/2007/7/10/492
