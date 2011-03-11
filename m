From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Fri, 11 Mar 2011 13:01:28 -0800 (PST)
Message-ID: <20110311.130128.71121155.davem@davemloft.net>
References: <20110310.155556.48513201.davem@davemloft.net>
	<AANLkTik3AyFTNoytebmOOZ=JSFMkt0bw7au-CSncUHJu@mail.gmail.com>
	<20110311204823.GB7906@fieldses.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110311204823.GB7906@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "J. Bruce Fields" <bfields@fieldses.org>
Date: Fri, 11 Mar 2011 15:48:23 -0500

> As with the above, it'd make the history a little more self-documenting.

Once there is even one single commit after the buggy one, this is
simply impossible since the hashes of subsequent commits depend upon
the precise contents of the original one.
