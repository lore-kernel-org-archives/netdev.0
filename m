From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Jun 21 (netdev: openvswitch)
Date: Fri, 21 Jun 2013 08:22:04 -0700
Message-ID: <51C46F9C.7020500@infradead.org>
References: <20130621181721.11783d80583444868725b62c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>, dev@openvswitch.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130621181721.11783d80583444868725b62c@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/21/13 01:17, Stephen Rothwell wrote:
> Hi all,
> 
> Happy solstice!
> 
> Changes since 20130620:
> 

when CONFIG_INET is not enabled:

  CC      net/openvswitch/flow.o
In file included from net/openvswitch/flow.c:43:0:
include/net/ip_tunnels.h: In function 'tunnel_ip_select_ident':
include/net/ip_tunnels.h:155:3: error: implicit declaration of function '__ip_select_ident' [-Werror=implicit-function-declaration]



-- 
~Randy
