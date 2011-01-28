From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 2/4] net: Make NETCONSOLE_DYNAMIC use select CONFIGFS_FS
Date: Fri, 28 Jan 2011 08:25:10 +0000 (UTC)
Message-ID: <ihtuh6$921$3@dough.gmane.org>
References: <1296155430-3796-1-git-send-email-nab@linux-iscsi.org>
	<1296155430-3796-3-git-send-email-nab@linux-iscsi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Jan 2011 11:10:28 -0800, Nicholas A. Bellinger wrote:

> From: Nicholas Bellinger <nab@linux-iscsi.org>
> 
> Convert 'depends && SYSFS && CONFIGFS_FS' to 'select CONFIGFS_FS'
> 

Acked-by: WANG Cong <xiyou.wangcong@gmail.com>

Thanks.
