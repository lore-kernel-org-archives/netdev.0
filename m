From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v2 0/7] Labeled networking patches for 2.6.28
Date: Mon, 11 Aug 2008 18:57:42 -0400
Message-ID: <200808111857.42859.paul.moore@hp.com>
References: <20080811212640.22551.17728.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080811212640.22551.17728.stgit@flek.lan>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 11 August 2008 6:23:49 pm Paul Moore wrote:
> [NOTE: in the process of writing the examples below I found a bug in
> the 'netlabelctl cipsov4 del ...' operation, I'm looking into it
> right now but in the meantime only add :) ]

I made some stupid mistakes in netlbl_cipsov4_remove() which should now 
be fixed in the git tree.

-- 
paul moore
linux @ hp
