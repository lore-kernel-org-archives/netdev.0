From: Joe Perches <joe@perches.com>
Subject: Re: [net-next PATCH] drivers/net/enic: Use (pr|netdev)_<level>
 macro helpers
Date: Thu, 03 Jun 2010 08:11:24 -0700
Message-ID: <1275577884.1703.11.camel@Joe-Laptop.home>
References: <C82CA5A9.3677A%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C82CA5A9.3677A%scofeldm@cisco.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-06-03 at 00:19 -0700, Scott Feldman wrote:
> I like the dev_name(dev) in there but not the "(unregister net_device)".
> Also there where a couple of lines longer than 80 chars.
> We can fix up the patch and resubmit if you like.

I'm not constrained by 80 char lines for formats.
Have at it.  Fix it up to your liking.

cheers, Joe
