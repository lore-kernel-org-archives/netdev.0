From: David Rientjes <rientjes@google.com>
Subject: Re: [net] b58537a1f56: +89.2% netperf.Throughput_Mbps
Date: Wed, 18 Jun 2014 13:29:03 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406181328160.10339@chino.kir.corp.google.com>
References: <53A10291.7090301@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Daniel Borkmann <dborkman@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, lkp@01.org,
	Fengguang Wu <fengguang.wu@intel.com>
To: Jet Chen <jet.chen@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53A10291.7090301@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Jun 2014, Jet Chen wrote:

> Hi Daniel,
> 
> FYI, we noticed the below changes on
> 
> commit b58537a1f5629bdc98a8b9dc2051ce0e952f6b4b ("net: sctp: fix permissions
> for rto_alpha and rto_beta knobs")
> 

There's no way this is legitimate, that commit cannot possibly affect the 
performance of netperf.  I wouldn't bother to spend any time investigating 
this.
