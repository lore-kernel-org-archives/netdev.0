From: Felipe W Damasio <felipewd@terra.com.br>
Subject: RE: NIC on 2.4.19 SMP (mii-diag output)
Date: 22 Oct 2002 21:49:49 +0000
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1035323389.714.33.camel@tank>
References: <FMEDJKFPPLANNCCEABDMCEKLCBAA.ph@digitalquake.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Linux-net <linux-net@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Paul Hernandez <ph@digitalquake.com>
In-Reply-To: <FMEDJKFPPLANNCCEABDMCEKLCBAA.ph@digitalquake.com>
List-Id: netdev.vger.kernel.org

On Mon, 2002-10-21 at 15:16, Paul Hernandez wrote:
>  I'm advertising 05e1: Flow-control 100baseTx-FD 100baseTx 10baseT-FD
> 10baseT
>    Advertising no additional info pages.
>    IEEE 802.3 CSMA/CD protocol.
>  Link partner capability is 0000:.
>    Negotiation did not complete.

	The link partner is not advertising it's capabilities.

	Can you reproduce this bug with 2.4.19 stock?

Felipe

