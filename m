From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] acx100 inclusion in mainline;
	generic 802.11 stack
Date: Tue, 31 Aug 2004 14:21:27 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <4134C1A7.50600@pobox.com>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: acx100-devel@lists.sourceforge.net, netdev@oss.sgi.com,
	Jouni Malinen <jkmaline@cc.hut.fi>,
	Jean Tourrilhes <jt@bougret.hpl.hp.com>, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

Denis Vlasenko wrote:
> I think 'senior' network guys are in position to decide upon which 
> of currently available 802.11 stacks we should continue to work.
> (Atheros has one, said to be derived from BSD, is there any others?)


Already have.  Start with the code in wireless-2.6 -- HostAP -- and use 
DaveM's 802.11 stack template as a model for actually integrating 802.11 
very tightly with the rest of the net stack.

http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/davem-p80211.tar.bz2

	Jeff
