From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: [PATCH 2.6.1] Net device error logging
Date: Tue, 20 Jan 2004 19:51:22 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040120195122.A1087@sygehus.dk>
References: <400C3D3E.BFCC25CE@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev <netdev@oss.sgi.com>,
	Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	"Feldman, Scott" <scott.feldman@intel.com>,
	Larry Kessler <kessler@us.ibm.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Jim Keniston <jkenisto@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <400C3D3E.BFCC25CE@us.ibm.com>; from jkenisto@us.ibm.com on Mon, Jan 19, 2004 at 12:25:34PM -0800
List-Id: netdev.vger.kernel.org

On Mon, Jan 19, 2004 at 12:25:34PM -0800, Jim Keniston wrote:
> The enclosed patch implements the netdev_* error-logging macros for
> network drivers.  These macros have been discussed at length on the
> linux-kernel and linux-netdev lists.  All issues that reviewers have
> raised were addressed previously.  This is just an update for v2.6.1.

How about a message rate limit?

-- 
Regards,
Rask Ingemann Lambertsen
