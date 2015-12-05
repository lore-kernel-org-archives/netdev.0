From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/1] atm: solos-pci: Replace simple_strtol by
 kstrtoint
Date: Sat, 05 Dec 2015 17:51:20 -0500 (EST)
Message-ID: <20151205.175120.236153071095458446.davem@davemloft.net>
References: <1449214999-6741-1-git-send-email-clabbe.montjoie@gmail.com>
	<1449214999-6741-2-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449214999-6741-2-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: LABBE Corentin <clabbe.montjoie@gmail.com>
Date: Fri,  4 Dec 2015 08:43:19 +0100

> The simple_strtol function is obsolete.
> This patch replace it by kstrtoint.
> This will simplify code, since some error case not handled by
> simple_strtol are handled by kstrtoint.
> 
> Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>

Applied to net-next, thanks.
