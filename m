From: "David S. Miller" <davem@redhat.com>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Sun, 8 Feb 2004 13:14:17 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040208131417.4f8693de.davem@redhat.com>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 8 Feb 2004 22:44:05 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> Comments?

This is a dicey situation in that when the entry does become
valid this does not trigger a proxy arp by us, does it?

I guess the original requestor will redo the request, so I'm
just mentioning this in passing.  This is an area where admittedly
I'm not well versed.

So proxy ARP experts speak up :)
