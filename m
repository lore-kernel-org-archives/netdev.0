From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v2 0/2] Labeled networking patches for 2.6.26
Date: Fri, 11 Apr 2008 08:04:32 +1000 (EST)
Message-ID: <Xine.LNX.4.64.0804110802140.1313@us.intercode.com.au>
References: <20080409204936.26774.55254.stgit@flek.lan> <200804101725.59604.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200804101725.59604.paul.moore@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 Apr 2008, Paul Moore wrote:

> Just a quick follow-up on testing, I've run this for a few hours on two 
> Fedora systems with both labeled and unlabeled IPsec in use with SAs 
> rekeying every 5 minutes and didn't notice anything evil.
> 
> At this point I'd strip the "RFC" from the patchset and ask that they be 
> considered for inclusion in 2.6.26 assuming there are no objections.

I suggest pushing them via DaveM's tree, unless they depend on anything in 
my tree.


- James
-- 
James Morris
<jmorris@namei.org>
