From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NUMA aware allocation of transmit and receive buffers
 for e1000
Date: Wed, 18 May 2005 09:49:12 +0200
Message-ID: <428AF378.5020109@cosmosbay.com>
References: <Pine.LNX.4.62.0505171854490.20408@graphe.net> <m1sm0l5lwa.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>, Christoph Lameter <christoph@graphe.net>
In-Reply-To: <m1sm0l5lwa.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Related question, is pci_alloc_consistent() already NUMA aware ?

Eric Dumazet
