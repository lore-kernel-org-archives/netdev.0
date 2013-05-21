From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 3/4] ixgbe: Add support for ndo_ll_poll
Date: Tue, 21 May 2013 00:14:44 -0700 (PDT)
Message-ID: <20130521.001444.1361294042663568537.davem@davemloft.net>
References: <CAJZOPZJx8vpSWqOhmN65gn=vi7hWXQO_J01+hAwGY9RwetX3DA@mail.gmail.com>
	<519B1A2B.4010909@linux.intel.com>
	<1369120003.25971.2.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eliezer.tamir@linux.intel.com, or.gerlitz@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, donald.c.skidmore@intel.com,
	e1000-devel@lists.sourceforge.net, willemb@google.com,
	andi@firstfloor.org, hpa@zytor.com, eliezer@tamir.org.il
To: eilong@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369120003.25971.2.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Tue, 21 May 2013 10:06:43 +0300

> Hopefully this series will be accepted so we can send follow up support
> for the bnx2x as well.

I think in two or three more iterations it will be merged.

There are no objections on the fundamentals, it's just implementation
details and coding style at this point.
