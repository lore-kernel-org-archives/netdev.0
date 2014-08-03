From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: pull request: wireless-next 2014-08-01
Date: Sat, 2 Aug 2014 21:06:49 -0700
Message-ID: <C1E000CB-3DC7-458D-B249-8EE08A8072DD@holtmann.org>
References: <20140801165738.GA26953@tuxdriver.com> <20140802.193939.2179004210212543536.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org Wireless"
	<linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140802.193939.2179004210212543536.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

>> Please pull this last(?) batch of wireless change intended for the
>> 3.17 stream...
> 
> When I pull this I get tons of conflicts for:
> 
> CONFLICT (content): Merge conflict in net/6lowpan/iphc.c
> 
> I don't feel comfortable fixing these up, where are they coming
> from?

they are coding style fixes to bring net/6lowpan/ in sync with net subsystem coding style. That code is still a bit outdated. I took a first stab at fixing the obvious mistakes.

Regards

Marcel
