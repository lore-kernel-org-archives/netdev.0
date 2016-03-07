From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net] sctp: fix copying more bytes than expected in
 sctp_add_bind_addr
Date: Tue, 8 Mar 2016 07:17:55 +0800
Message-ID: <201603080758.oSIf1B2b%fengguang.wu@intel.com>
References: <6cddeac76bb79521e58f9bbba653db774191eb1c.1457382433.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org, dvyukov@google.com,
	nhorman@tuxdriver.com, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org, linux-kernel@vger.kernel.org,
	syzkaller@googlegroups.com, kcc@google.com, glider@google.com,
	sasha.levin@oracle.com, edumazet@google.com, davem@davemloft.net
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6cddeac76bb79521e58f9bbba653db774191eb1c.1457382433.git.marcelo.leitner@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcelo,

[auto build test WARNING on net/master]

url:    https://github.com/0day-ci/linux/commits/Marcelo-Ricardo-Leitner/sctp-fix-copying-more-bytes-than-expected-in-sctp_add_bind_addr/20160308-052009


coccinelle warnings: (new ones prefixed by >>)

>> net/sctp/bind_addr.c:458:42-48: ERROR: application of sizeof to pointer

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
