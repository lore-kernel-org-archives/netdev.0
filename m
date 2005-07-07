From: Mitch Williams <mitch.a.williams@intel.com>
Subject: Re: [PATCH 2.6.13-rc1 8/17] bonding: SYSFS INTERFACE (large)
Date: Thu, 7 Jul 2005 16:32:30 -0700
Message-ID: <Pine.CYG.4.58.0507071631200.2576@mawilli1-desk2.amr.corp.intel.com>
References: <20050706190906.74128.qmail@web81301.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>, netdev@oss.sgi.com,
        "Godse, Radheka" <radheka.godse@intel.com>, fubar@us.ibm.com,
        bonding-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Dmitry Torokhov <dtor_core@ameritech.net>
In-Reply-To: <20050706190906.74128.qmail@web81301.mail.yahoo.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 6 Jul 2005, Dmitry Torokhov wrote:

> Semaphore will not help in scenario you described:

Phooey.  You're absolutely right.  I'll have to go back and rework this
stuff using the reference count.

Thanks again for your efforts on this.

-Mitch
