From: "David S. Miller" <davem@davemloft.net>
Subject: Re: strange network slowness in 2.6 unless pingflooding
Date: Mon, 27 Sep 2004 16:18:45 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040927161845.1442bb4a.davem@davemloft.net>
References: <20040927090342.GA1794@zip.com.au>
	<41587A26.6020606@conectiva.com.br>
	<20040927224957.GA1043@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: CaT <cat@zip.com.au>
In-Reply-To: <20040927224957.GA1043@zip.com.au>
List-Id: netdev.vger.kernel.org

On Tue, 28 Sep 2004 08:49:57 +1000
CaT <cat@zip.com.au> wrote:

> It does not help. Same problem as before.

Please give us some exact specifics about your network setup
so that someone can possibly reproduce your problem locally.
In particular, if there are hubs or switches involved on
your local network that might be getting the duplex wrong,
or some NAT or firewall machines in the path in question,
please specify their setup precisely.

Otherwise there is zero chance of this problem ever being
fixes.
