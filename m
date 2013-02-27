From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH 0/5] net: low latency Ethernet device polling
Date: Wed, 27 Feb 2013 10:13:54 -0800
Message-ID: <20130227101354.15636ba5@nehalam.linuxnetplumber.net>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Have you looked at netmap? Seems like a cleaner user API for this.

There is a version for Linux, but it needs work. My plan is to send it staging
(after merge window reopens).
