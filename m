From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC:  Redirect-Device
Date: Thu, 31 Mar 2005 13:02:05 -0800
Message-ID: <20050331130205.4da3a025.davem@davemloft.net>
References: <424C6089.1080507@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <424C6089.1080507@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


My only comment is to either use something other than ioctls or realize
that fs/compat_ioctl.c entries for your new ioctls will be needed.
