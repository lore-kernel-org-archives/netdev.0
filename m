From: Matthew Wilcox <willy@debian.org>
Subject: Re: [PATCH] netdev_ops
Date: Thu, 10 Jul 2003 12:21:49 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030710112149.GC1939@parcelfarce.linux.theplanet.co.uk>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102229133@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@debian.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
Content-Disposition: inline
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102229133@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jul 10, 2003 at 12:47:13AM -0700, Feldman, Scott wrote:
> Can we get a HAVE_NETDEV_OPS?

I'll seriously consider it ... once we have a better idea where this is
all going.  I'm a big fan of having _shared_ compatibility code rather
than something in each driver.  Obviously we'll want to share drivers
between 2.4 and 2.6.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
