From: Andrew Morton <akpm@osdl.org>
Subject: Re: A new 10GB Ethernet Driver by Chelsio Communications
Date: Fri, 11 Mar 2005 11:21:32 -0800
Message-ID: <20050311112132.6a3a3b49.akpm@osdl.org>
References: <Pine.LNX.4.58.0503110356340.14213@server.graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mark@chelsio.com, netdev@oss.sgi.com,
	Jeff Garzik <jgarzik@pobox.com>
To: Christoph Lameter <christoph@graphe.net>
In-Reply-To: <Pine.LNX.4.58.0503110356340.14213@server.graphe.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter <christoph@graphe.net> wrote:
>
> A Linux driver for the Chelsio 10Gb Ethernet Network Controller by
>  Chelsio (http://www.chelsio.com). This driver supports the Chelsio N210
>  NIC and is backward compatible with the Chelsio N110 model 10Gb NICs.

Thanks, Christoph.

The 400k patch was too large for the vger email server so I have uploaded it to

 http://www.zip.com.au/~akpm/linux/patches/stuff/a-new-10gb-ethernet-driver-by-chelsio-communications.patch

for reviewers.

> It supports AMD64, EM64T and x86 systems.

Is it only supported on those systems?  If so, why is that?
