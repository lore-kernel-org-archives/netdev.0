From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/2] staging: lustre: lnet: lnet: do not initialise
 statics to 0 or NULL
Date: Fri, 31 Oct 2014 13:50:24 -0700
Message-ID: <20141031205024.GB20417@kroah.com>
References: <20141031181808.GA7830@vasu-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andreas.dilger@intel.com, oleg.drokin@intel.com
To: Balavasu <kp.balavasu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141031181808.GA7830@vasu-Inspiron-3542>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 31, 2014 at 11:48:08PM +0530, Balavasu wrote:
> This patch fixes the checkpatch.pl issue
> Error: do not initialise statics to 0 or NULL for time
> 
> Signed-off-by: Balavasu <kp.balavasu@gmail.com>
> ---
>  drivers/staging/lustre/lnet/lnet/do not instalise 0 | 10 +++++-----

That line doesn't look right, does it?

And why netdev and not the mailing list for the drivers/staging/ tree?

And again, I need a full name.

greg k-h
