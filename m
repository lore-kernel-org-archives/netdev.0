From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for October 13 (net/3c59x)
Date: Wed, 13 Oct 2010 09:38:36 -0700
Message-ID: <20101013093836.1ee6f2f9.randy.dunlap@oracle.com>
References: <20101013154522.7b087a20.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20101013154522.7b087a20.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Oct 2010 15:45:22 +1100 Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20101012:


when CONFIG_PCI is not enabled:

drivers/net/3c59x.c:3211: error:request for member 'current_state' in something not a structure or union

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
