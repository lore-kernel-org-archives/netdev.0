From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch] 2.4 lacks dummy SET_NETDEV_DEV
Date: Mon, 10 Nov 2003 22:14:29 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031110221429.04732a57.davem@redhat.com>
References: <20031110181917.GA25846@ee.oulu.fi>
	<20031110221430.GA26556@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20031110221430.GA26556@ee.oulu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 11 Nov 2003 00:14:30 +0200
Pekka Pietikainen <pp@ee.oulu.fi> wrote:

> (I still like the idea of being able to use exactly the same driver
> source on 2.4/2.6 though)

I agree, someone should merge in the dummy SET_NETDEV_DEV once
Marcelo starts up 2.4.24-preX
