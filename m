From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2011-08-22
Date: Mon, 22 Aug 2011 12:33:26 -0700 (PDT)
Message-ID: <20110822.123326.1795268471389412471.davem@davemloft.net>
References: <20110822190136.GJ2534@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110822190136.GJ2534@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 22 Aug 2011 15:01:37 -0400

> This is a batch of fixes intended for 3.1.  Included is rewrite of an
> earlier iwlagn fix that was revealed to be flawed (bad pointer access
> during module unload), a fix for a memory leak, and a trio of rt2x00
> fixes with detailed changelogs.  These have all been in linux-next
> for the last week with no reported complaints.
> 
> Please let me know if there are problems!

Pulled, thanks John.
