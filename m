From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: fix compilation when RSS is disabled
Date: Sun, 28 Nov 2010 18:26:35 -0800 (PST)
Message-ID: <20101128.182635.59677769.davem@davemloft.net>
References: <1290890035-32285-1-git-send-email-scottjg@vmware.com>
	<1290890035-32285-2-git-send-email-scottjg@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org, pv-drivers@vmware.com,
	randy.dunlap@oracle.com
To: scottjg@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290890035-32285-2-git-send-email-scottjg@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Scott J. Goldman" <scottjg@vmware.com>
Date: Sat, 27 Nov 2010 12:33:55 -0800

> If RSS is disabled, we can ifdef out some RSS specific code. This fixes
> the compile error found by Randy Dunlap.
> 
> Signed-off-by: Scott J. Goldman <scottjg@vmware.com>

Applied.
