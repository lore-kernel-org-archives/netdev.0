From: "David S. Miller" <davem@redhat.com>
Subject: Re: Bug? ARP with wrong src IP address
Date: Thu, 24 Jul 2003 09:10:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030724091007.68923845.davem@redhat.com>
References: <200307241728270476.0031BAB0@192.168.128.16>
	<Pine.LNX.4.44.0307241849341.2177-100000@l>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: carlosev@newipnet.com, bdschuym@pandora.be, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0307241849341.2177-100000@l>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 24 Jul 2003 18:54:04 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> The most used feature for such setups:
> http://www.ssi.bg/~ja/#hidden

The hidden patch is not necessary with current kernels and arpfilter.
