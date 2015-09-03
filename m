From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Thu, 03 Sep 2015 11:46:45 -0700 (PDT)
Message-ID: <20150903.114645.362862619038806147.davem@davemloft.net>
References: <CA+55aFx=xh4+vCNOgwXyfeV-t=6anXimqBxH_i71RjYy+Gy9-w@mail.gmail.com>
	<20150903.104032.767889134756094076.davem@davemloft.net>
	<CA+55aFxtD2VYW2R0JwjFkZkvzQzcN7qK3m6ReR+BBXtfyDHx7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lorenzo.bianconi83@gmail.com, johannes.berg@intel.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxtD2VYW2R0JwjFkZkvzQzcN7qK3m6ReR+BBXtfyDHx7g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 3 Sep 2015 11:22:10 -0700

> (note the lack of warning about the use of an array in the function
> definition parameter list - I tried to find if there's any way to
> enable such a warning, but couldn't find anything. Maybe my google-fu
> is weak, but more probably that just doesn't exist).

I would love to see such a warning if it doesn't exist.
