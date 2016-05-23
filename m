From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ptp: use memdup_user().
Date: Mon, 23 May 2016 14:05:47 -0700 (PDT)
Message-ID: <20160523.140547.194027000303214592.davem@davemloft.net>
References: <1463746862-23815-1-git-send-email-falakreyaz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: falakreyaz@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463746862-23815-1-git-send-email-falakreyaz@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Muhammad Falak R Wani <falakreyaz@gmail.com>
Date: Fri, 20 May 2016 17:51:02 +0530

> Use memdup_user to duplicate a memory region from user-space to
> kernel-space, instead of open coding using kmalloc & copy_from_user.
> 
> Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>

Applied.
