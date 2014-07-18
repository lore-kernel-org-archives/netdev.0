From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net 4/4] xen-netback: Fix pointer incrementation to avoid
 incorrect logging
Date: Fri, 18 Jul 2014 16:25:08 +0100
Message-ID: <20140718152508.GQ7142@zion.uk.xensource.com>
References: <1405624192-21722-1-git-send-email-zoltan.kiss@citrix.com>
 <1405624192-21722-5-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1405624192-21722-5-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 17, 2014 at 08:09:52PM +0100, Zoltan Kiss wrote:
> Due to this pointer is increased prematurely, the error log contains rubbish.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Reported-by: Armin Zentai <armin.zentai@ezit.hu>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: xen-devel@lists.xenproject.org

Acked-by: Wei Liu <wei.liu2@citrix.com>
