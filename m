From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] fix select() for SOCK_RAW sockets
Date: Tue, 7 Dec 2004 21:28:17 -0800
Message-ID: <20041207212817.1b74671b.davem@davemloft.net>
References: <20041207003525.GA22933@linuxace.com>
	<20041207025218.GB61527@gaz.sfgoth.com>
	<20041207045302.GA23746@linuxace.com>
	<20041207054840.GD61527@gaz.sfgoth.com>
	<20041207150834.GA75700@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kernel@linuxace.com, shemminger@osdl.org,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20041207150834.GA75700@gaz.sfgoth.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 7 Dec 2004 07:08:34 -0800
Mitchell Blank Jr <mitch@sfgoth.com> wrote:

> Davem: I only tested that this doesn't break UDP; if it works for Phil and
> Stephen can verify that it doesn't break his bad-checksum UDP tests then
> please push it for 2.6.10.

Looks good Mitchell, patch applied.

Thanks.
