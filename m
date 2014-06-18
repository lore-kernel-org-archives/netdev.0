From: David Rientjes <rientjes@google.com>
Subject: Re: [net] b58537a1f56: +89.2% netperf.Throughput_Mbps
Date: Wed, 18 Jun 2014 13:41:18 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406181340380.13111@chino.kir.corp.google.com>
References: <53A10291.7090301@intel.com> <alpine.DEB.2.02.1406181328160.10339@chino.kir.corp.google.com> <53A1F8D9.7070704@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jet Chen <jet.chen@intel.com>, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, lkp@01.org,
	Fengguang Wu <fengguang.wu@intel.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53A1F8D9.7070704@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Jun 2014, Daniel Borkmann wrote:

> One assumption could be that netperf was setting this knob
> internally and ignoring the result of it (error/success), but
> that we might need to look up in netperf source to confirm.
> 

Confirmed netperf-2.4.5 doesn't do this.
