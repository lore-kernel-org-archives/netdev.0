From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v1 0/6] Labeled networking patches for 2.6.28
Date: Fri, 8 Aug 2008 22:18:43 -0400
Message-ID: <200808082218.43511.paul.moore@hp.com>
References: <20080808203542.21077.37084.stgit@flek> <20080808.160957.43829121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080808.160957.43829121.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 08 August 2008 7:09:57 pm David Miller wrote:
> From: Paul Moore <paul.moore@hp.com>
> Date: Fri, 08 Aug 2008 16:52:45 -0400
>
> > Attached is a short series of patches which fixup some issues with
> > labeled networking and add an important new feature: NetLabel
> > address selectors.
>
> If relevant, please submit the bug fix parts for 2.6.27, thanks.

Most of the "problems" I've "fixed" haven't really been bugs, but rather 
issues that made the new features difficult to implement.  The one 
exception may be the first patch in the series; I've debated submitting 
it for 2.6.27 but I'm not sure if it is significant.  Perhaps the 
SELinux folks could comment on this, if they think it is a good idea 
I'll respin that patch and push it for 2.6.27.

-- 
paul moore
linux @ hp
