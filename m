From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Get rid of sk_protinfo use in netrom
Date: Wed, 23 Mar 2005 11:17:01 -0800
Message-ID: <20050323111701.43e31617.davem@davemloft.net>
References: <20050321094905.GA10022@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-hams@vger.kernel.org
To: Ralf Baechle DL5RB <ralf@linux-mips.org>
In-Reply-To: <20050321094905.GA10022@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Mar 2005 09:49:05 +0000
Ralf Baechle DL5RB <ralf@linux-mips.org> wrote:

> Below patch puts struct sock into nr_cb to get rid of the need for the
> use of sk_protinfo in nr_sk().  While we're touching the data structure
> convert it from a typedef into a struct.

Applied, thanks Ralf.
