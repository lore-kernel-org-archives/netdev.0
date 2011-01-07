From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH v2] net: ppp: use {get,put}_unaligned_be{16,32}
Date: Fri, 7 Jan 2011 14:01:45 +1100
Message-ID: <20110107030145.GA8021@brick.ozlabs.ibm.com>
References: <1294357056-25889-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Harvey Harrison <harvey.harrison@gmail.com>,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1294357056-25889-1-git-send-email-xiaosuo@gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 07, 2011 at 07:37:36AM +0800, Changli Gao wrote:

> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

This patch description is inadequate.  It should tell us why you are
making this change.  Does it result in smaller and/or faster code, and
if so by how much on what sort of machine?  Do you think it makes the
code clearer?  (I don't.)  Or is there some other motivation for this?

Paul.
