From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 2.6] e100, e1000, ixgb: add MODULE_VERSION tags
Date: Tue, 2 Nov 2004 15:06:39 -0500
Message-ID: <20041102150639.A19501@tuxdriver.com>
References: <20041102190724.GA6962@lists.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux.nics@intel.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Domsch <Matt_Domsch@dell.com>
Content-Disposition: inline
In-Reply-To: <20041102190724.GA6962@lists.us.dell.com>; from Matt_Domsch@dell.com on Tue, Nov 02, 2004 at 01:07:24PM -0600
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Nov 02, 2004 at 01:07:24PM -0600, Matt Domsch wrote:
> Patch below adds MODULE_VERSION tags to the e100, e1000, and ixgb
> drivers.  Tools like DKMS will make use of this information to

I had recently posted patches to this effect for e100, e1000 (nearly
identical to yours) and several others.  I did not, however, include
ixgb, so I'm sure that one will be quite welcome! :-)

John
-- 
John W. Linville
linville@tuxdriver.com
