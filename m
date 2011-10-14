From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH] staging: hv: move hv_netvsc out of staging area
Date: Fri, 14 Oct 2011 19:28:21 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC096F8090@TK5EX14MBXC227.redmond.corp.microsoft.com>
References: <1318620026-8349-1-git-send-email-haiyangz@microsoft.com>
	<20111014191605.GA31039@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.osdl.org" <virtualization@lists.osdl.org>,
	Mike Sterling <Mike.Sterling@microsoft.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: Greg KH <gregkh@suse.de>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <20111014191605.GA31039@suse.de>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Greg KH [mailto:gregkh@suse.de]
> Sent: Friday, October 14, 2011 3:16 PM
> Because of renames, the network developers really can't review this.
> I
> suggest posting a new patch, that just adds the driver to the
> drivers/net/ directory, and have the network developer review it that
> way.
> 
> Then, when it is accepted, I can delete the version in the staging
> directory.  We've done it this way for other drivers and it is the
> best
> way to get proper reviews as well as handling cross-subsystem merge
> issues.

During the previous review in June, Joe Perches suggested me to use -M 
option to show only changed code. But I will make a new patch to show 
all code according to your request.

Thanks,
- Haiyang
