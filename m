From: Joel Becker <Joel.Becker@oracle.com>
Subject: Re: [PATCH -mm 8/9] netconsole: Update documentation for dynamic reconfigurability
Date: Wed, 4 Jul 2007 23:52:14 -0700
Message-ID: <20070705065213.GH17650@tasint.org>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in> <20070704110819.28520.50445.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>, Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:20800 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756900AbXGEGwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 02:52:43 -0400
Content-Disposition: inline
In-Reply-To: <20070704110819.28520.50445.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 04, 2007 at 04:38:19PM +0530, Satyam Sharma wrote:
> +Some examples follow (configfs is mounted at the /config mountpoint, say).

	configfs is generally expected to be mounted at
/sys/kernel/config, and it even creates that mountpoint for itself.  The
documentation should probably be consistent with that.

Joel

-- 

"Also, all of life's big problems include the words 'indictment' or
	'inoperable.' Everything else is small stuff."
	- Alton Brown

Joel Becker
Principal Software Developer
Oracle
E-mail: joel.becker@oracle.com
Phone: (650) 506-8127
