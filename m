From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] selftests: add a generic testsuite for ethernet
 device
Date: Wed, 05 Apr 2017 08:30:32 -0700 (PDT)
Message-ID: <20170405.083032.2285292067898802646.davem@davemloft.net>
References: <20170404133247.28725-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shuah@kernel.org, andrew@lunn.ch, linux-kselftest@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170404133247.28725-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Tue,  4 Apr 2017 15:32:47 +0200

> This patch add a generic testsuite for testing ethernet network device driver.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
> 
> Changes since v1:
> - Test for starting master interface
> - Changed printing format to "RESULT: $netdev: line"
> - Use "ip link" to get device list

Applied, thanks.
