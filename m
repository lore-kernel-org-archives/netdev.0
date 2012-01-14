From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pch_gbe: Use a randomly generated MAC instead of
 failing probe
Date: Sat, 14 Jan 2012 00:15:25 -0800 (PST)
Message-ID: <20120114.001525.2158050844390627233.davem@davemloft.net>
References: <132d2a41a089905de3147b4656e350608aa7fd6f.1326523495.git.dvhart@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, arjan@linux.intel.com,
	alan@linux.intel.com, tomoya.rohm@gmail.com,
	jeffrey.t.kirsher@intel.com, paul.gortmaker@windriver.com,
	jdmason@kudzu.us, netdev@vger.kernel.org
To: dvhart@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <132d2a41a089905de3147b4656e350608aa7fd6f.1326523495.git.dvhart@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Darren Hart <dvhart@linux.intel.com>
Date: Fri, 13 Jan 2012 22:44:55 -0800

> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com> (commit_signer:1/3=33%,commit_signer:1/8=12%)

BTW, please try to figure out where this "commit_signer" stuff came from.

It ended up corrupting the CC: list of your posting too.
