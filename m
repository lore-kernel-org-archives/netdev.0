From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cisco: enic: Update logging macros and uses
Date: Fri, 11 Mar 2016 15:08:12 -0500 (EST)
Message-ID: <20160311.150812.1296153063421521729.davem@davemloft.net>
References: <fd7e962bc72778fc1f2a9b21742eff2eb19d9bd8.1457474066.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benve@cisco.com, ssujith@cisco.com, _govind@gmx.com,
	neepatel@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fd7e962bc72778fc1f2a9b21742eff2eb19d9bd8.1457474066.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue,  8 Mar 2016 13:54:56 -0800

> Don't hide varibles used by the logging macros.
> 
> Miscellanea:
> 
> o Use the more common ##__VA_ARGS__ extension
> o Add missing newlines to formats
> o Realign arguments
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
