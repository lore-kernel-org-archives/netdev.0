From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v6 10/16] netlabel: Add network address selectors to
 the NetLabel/LSM domain mapping
Date: Wed, 1 Oct 2008 19:14:23 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0810011914070.6732@tundra.namei.org>
References: <20080916124722.17132.38741.stgit@flek.lan> <20080916125654.17132.86183.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080916125654.17132.86183.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Sep 2008, Paul Moore wrote:

> This patch extends the NetLabel traffic labeling capabilities to individual
> packets based not only on the LSM domain but the by the destination address
> as well.  The changes here only affect the core NetLabel infrastructre,
> changes to the NetLabel KAPI and individial protocol engines are also
> required but are split out into a different patch to ease review.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Reviewed-by: James Morris <jmorris@namei.org>


-- 
James Morris
<jmorris@namei.org>
