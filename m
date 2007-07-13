From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH] try parent numa_node at first before using default
Date: Thu, 12 Jul 2007 21:42:12 -0700
Message-ID: <86802c440707122142t796aaf29v46403cc50c7ba4ea@mail.gmail.com>
References: <200707101641.17672.yinghai.lu@sun.com>
	 <469610D4.70009@s5r6.in-berlin.de>
	 <20070712172310.4d662e1f@gondolin.boeblingen.de.ibm.com>
	 <200707121059.54320.yinghai.lu@sun.com>
	 <20070712183141.GB22471@kroah.com>
	 <86802c440707121206i3186fe9chba55fe2e5e5e4c5@mail.gmail.com>
	 <20070713031622.GC2395@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Cornelia Huck" <cornelia.huck@de.ibm.com>,
	"Stefan Richter" <stefanr@s5r6.in-berlin.de>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Andi Kleen" <ak@suse.de>, rientjes@google.com,
	"Christoph Lameter" <clameter@sgi.com>,
	"Christoph Hellwig" <hch@infradead.org>,
	"David Miller" <davem@davemloft.net>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Greg KH" <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.229]:14021 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758093AbXGMEmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 00:42:14 -0400
Received: by nz-out-0506.google.com with SMTP id s18so342335nze
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2007 21:42:13 -0700 (PDT)
In-Reply-To: <20070713031622.GC2395@kroah.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/12/07, Greg KH <greg@kroah.com> wrote:
>
> But you were not able to test USB, right?  Does that work properly now
> with this patch?

Will test it later with USB cdrom by big file reading.

YH
