From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 - dac testing (was: [mini-RFT] r8169 and amd64)
Date: Thu, 21 Oct 2004 09:33:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021073333.GA29423@electric-eye.fr.zoreil.com>
References: <200410221112.18575.sriharivijayaraghavan@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Srihari Vijayaraghavan <sriharivijayaraghavan@yahoo.com.au>
Content-Disposition: inline
In-Reply-To: <200410221112.18575.sriharivijayaraghavan@yahoo.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Srihari Vijayaraghavan <sriharivijayaraghavan@yahoo.com.au> :
[...]
> r8169: eth0: PCI error (cmd = 0x0017, status = 0x22b0).
> eth1: link up, 100Mbps, full-duplex, lpa 0x45E1
> 
> And the network card does not work, as I cannot ping another host (DSL 
> modem/router) on the network.
> 
> (Once I load the module with that parameter, unloading and reloading it 
> without that parameter does not bring the network card back to its working 
> configuration.)

Thanks a lot.

- it does not crash but it did not recover;
- no difference with the newly reported PCI error under load on a 32bit host.

Bad mojo.

--
Ueimor
> 
