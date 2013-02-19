From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atl1c: restore buffer state
Date: Tue, 19 Feb 2013 13:19:53 -0500 (EST)
Message-ID: <20130219.131953.1403463983805165846.davem@davemloft.net>
References: <1361294589-7316-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qca-linux-team@qca.qualcomm.com, nic-devel@qca.qualcomm.com,
	jwboyer@redhat.com
To: xiong@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361294589-7316-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: xiong <xiong@qca.qualcomm.com>
Date: Wed, 20 Feb 2013 01:23:09 +0800

> in the previous commit : f1f220ea1dda078, the BUSY state of buffer is wrongly
> deleted. this patch just restore it.
> 
> Signed-off-by: xiong <xiong@qca.qualcomm.com>

Applied.
