From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Mon, 9 Feb 2004 00:44:26 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402090036330.6268@u.domain.uli>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
 <20040208131417.4f8693de.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040208131417.4f8693de.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Sun, 8 Feb 2004, David S. Miller wrote:

> So proxy ARP experts speak up :)

	I found that it is better not to delay answers to unicast
probes. In case I change other things, I'll keep latest version of this 
patch here:

http://www.ssi.bg/~ja/tmp/
arp_proxy-*.diff

Regards

--
Julian Anastasov <ja@ssi.bg>
