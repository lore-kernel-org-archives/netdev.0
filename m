From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] netdev_ops
Date: Thu, 10 Jul 2003 09:06:42 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0D64E2.9000801@pobox.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102229133@orsmsx402.jf.intel.com> <20030710112149.GC1939@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Feldman, Scott" <scott.feldman@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
In-Reply-To: <20030710112149.GC1939@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> On Thu, Jul 10, 2003 at 12:47:13AM -0700, Feldman, Scott wrote:
> 
>>Can we get a HAVE_NETDEV_OPS?
> 
> 
> I'll seriously consider it ... once we have a better idea where this is
> all going.  I'm a big fan of having _shared_ compatibility code rather
> than something in each driver.  Obviously we'll want to share drivers
> between 2.4 and 2.6.


Something like... oh... kcompat?  :)

http://sf.net/projects/gkernel/
