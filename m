From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: linux-next: Tree for Nov 28 (netlabel)
Date: Mon, 28 Nov 2011 10:16:23 -0800
Message-ID: <4ED3CFF7.9090502@xenotime.net>
References: <20111128162556.47758629406b638a99428049@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, Paul Moore <paul@paul-moore.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20111128162556.47758629406b638a99428049@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/27/2011 09:25 PM, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20111125:

When IPV6 is not enabled:

net/netlabel/netlabel_kapi.c: In function 'netlbl_cfg_unlbl_map_add':
net/netlabel/netlabel_kapi.c:165:4: error: implicit declaration of function 'netlbl_af6list_add'


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
