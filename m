From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [Patch 1/3 2.5] e1000: Configuration and user guide update
Date: Fri, 15 Oct 2004 12:32:36 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416FFBA4.1080001@pobox.com>
References: <Pine.LNX.4.44.0410150515070.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
In-Reply-To: <Pine.LNX.4.44.0410150515070.31227-100000@isotope.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ganesh Venkatesan wrote:
> diff -Nuarp old/linux-2.5/Documentation/networking/e1000.txt new/linux-2.5/Documentation/networking/e1000.txt
> --- old/linux-2.5/Documentation/networking/e1000.txt	2004-10-07 15:50:44.000000000 -0700
> +++ new/linux-2.5/Documentation/networking/e1000.txt	2004-10-07 15:51:15.000000000 -0700

all three patches in this series look OK, but are rejected due to 
invalid patch header (see previous emails with details).

Your patch _must_ be apply-able with "patch -sp1 < patch"

	Jeff
