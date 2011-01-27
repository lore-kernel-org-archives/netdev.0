From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH RESEND 0/4] Fix kconfig breakage wrt to CONFIGFS_FS
Date: Thu, 27 Jan 2011 20:41:57 +0100
Message-ID: <20110127194157.GA7565@elte.hu>
References: <1296155430-3796-1-git-send-email-nab@linux-iscsi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>,
	Joel Becker <jlbec@evilplan.org>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Americo Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1296155430-3796-1-git-send-email-nab@linux-iscsi.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Nicholas A. Bellinger <nab@linux-iscsi.org> wrote:

> From: Nicholas Bellinger <nab@linux-iscsi.org>
> 
> Hi Linus,
> 
> The following four patches are to address recent Kconfig CONFIGFS_FS ->
> 'select SYSFS' change for GFS2_FS, and 'depends && SYSFS && CONFIGFS_FS'
> breakage for NETCONSOLE_DYNAMIC, DLM, and OCFS2_FS in .38-rc2.
> 
> Please review and consider pulling from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/nab/scsi-post-merge-2.6.git for-linus-v2

I had the original for-linus branch tested rather extensively, and that one had no 
problems. What's different in -v2?

Thanks,

	Ingo
