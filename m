From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Passive OS fingerprinting.
Date: Wed, 2 Jul 2008 08:46:28 +0400
Message-ID: <20080702044628.GA11252@2ka.mipt.ru>
References: <20080701113927.GA16343@2ka.mipt.ru> <20080701195648.GD7488@linux.vnet.ibm.com> <20080701212139.GA18619@2ka.mipt.ru> <20080701224149.GA8449@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080701224149.GA8449@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 01, 2008 at 03:41:49PM -0700, Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> Glad it wasn't just me going senile!!!  ;-)
> 
> Will you be fixing the procfs stuff as well?  If not, could you please
> send a pointer?

I will, probably just by moving to netlink. I think I will also
implement kind of hash table for fingerprint set.

-- 
	Evgeniy Polyakov
