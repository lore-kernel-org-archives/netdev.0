From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v2 0/2] net: start kdoc'ifying net_device
Date: Thu, 27 Feb 2014 15:59:35 -0500 (EST)
Message-ID: <20140227.155935.2071416701209004953.davem@redhat.com>
References: <1393377313-28695-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org
To: mcgrof@do-not-panic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393377313-28695-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Date: Tue, 25 Feb 2014 17:15:11 -0800

> While working on extending some functionality I felt restricted
> with the amount of documentation I can add. Part of this is that
> the existing style on the header files don't let me be verbose.
> This starts addressing that by using kdoc for the net_device
> flags, and as Ben noted, the priv_flags can be moved out from
> UAPI.

Series applied, thanks Luis.
