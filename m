From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 4/4] bonding: Convert memcpy(foo, bar,
 ETH_ALEN) to ether_addr_copy(foo, bar)
Date: Mon, 10 Mar 2014 08:00:00 -0700
Message-ID: <1394463600.24244.0.camel@joe-AO722>
References: <cover.1392508410.git.joe@perches.com>
	 <0022868482b6f5a6d723992e0802470771066cb1.1392508410.git.joe@perches.com>
	 <20140310094945.GA2864@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	linux-kernel@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140310094945.GA2864@minipsycho.orion>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-03-10 at 10:49 +0100, Jiri Pirko wrote:
> Many times, the original len ETH_ALEN was wrong. Bonding should work
> with other types than Ethernet as well.

It's been applied already.

Feel free to send patches to correct
whatever you think needs updating.
