From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Fri, 11 Feb 2005 17:08:17 -0800
Message-ID: <20050211170817.39d581b5.davem@davemloft.net>
References: <0525M9211@server5.heliogroup.fr>
	<420D37A3.6020209@hp.com>
	<420D3B17.3040506@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, hubert.tonneau@fullpliant.org, shemminger@osdl.org,
        romieu@fr.zoreil.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <420D3B17.3040506@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 11 Feb 2005 15:09:11 -0800
Nivedita Singhvi <niv@us.ibm.com> wrote:

> Er, how is this compliant with 2581 (yes, I know, it's only
> a SHOULD, not a MUST)  - an ACK should be generated for at
> least every second full-sized segment received?

It's compliant but stupid.
