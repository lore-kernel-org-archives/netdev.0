From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v6 03/16] netlabel: Remove unneeded in-kernel API
 functions
Date: Wed, 1 Oct 2008 11:38:36 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0810011138150.5277@tundra.namei.org>
References: <20080916124722.17132.38741.stgit@flek.lan> <20080916125607.17132.84448.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080916125607.17132.84448.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Sep 2008, Paul Moore wrote:

> After some discussions with the Smack folks, well just Casey, I now have a
> better idea of what Smack wants out of NetLabel in the future so I think it
> is now safe to do some API "pruning".  If another LSM comes along that
> needs this functionality we can always add it back in, but I don't see any
> LSMs on the horizon which might make use of these functions.
> 
> Thanks to Rami Rosen who suggested removing netlbl_cfg_cipsov4_del() back
> in February 2008.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Reviewed-by: James Morris <jmorris@namei.org>



-- 
James Morris
<jmorris@namei.org>
